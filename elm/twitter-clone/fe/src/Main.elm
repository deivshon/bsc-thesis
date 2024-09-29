module Main exposing (main)

import Api
import Browser
import Browser.Navigation as Nav
import Html as H exposing (Html)
import Html.Events as HE
import Http
import Login
import Models.Pagination as Pagination
import Ports.Ports exposing (noInteractionTokenChange, removeToken, storeToken)
import Post
import Url
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf)
import User


type alias Flags =
    { authToken : Maybe String
    }


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


subscriptions : a -> Sub Msg
subscriptions _ =
    noInteractionTokenChange TokenChangedInOtherTab


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , page : Page
    , authToken : Maybe String
    , loginData : Login.LoginData
    , signupData : Login.LoginData
    , postsData : Post.PostsData
    , userPostsData : Post.PostsData
    , newPost : String
    }


type Page
    = Login
    | Home
    | UserPage String
    | NotFound


postsToMsg : Result error (List Post.Post) -> Msg
postsToMsg postsResult =
    case postsResult of
        Ok posts ->
            NewPostsLoaded posts

        Err _ ->
            PostsErrored


userPostsToMsg : Result error (List Post.Post) -> Msg
userPostsToMsg postsResult =
    case postsResult of
        Ok posts ->
            NewUserPostsLoaded posts

        Err _ ->
            UserPostsErrored


newPostToMsg : Result error Post.Post -> Msg
newPostToMsg newPostResult =
    case newPostResult of
        Ok newPost ->
            NewPostCreationSucceeded newPost

        Err _ ->
            NewPostCreationFailed


withDifferentLikeStatus : Model -> String -> Bool -> Model
withDifferentLikeStatus model postId liked =
    let
        currentPostsData =
            model.postsData

        currentUserPostsData =
            model.userPostsData

        adjustedPostsData =
            { currentPostsData
                | posts =
                    if liked then
                        Post.setPostLikedInList postId currentPostsData.posts

                    else
                        Post.setPostNotLikedInList postId currentPostsData.posts
            }

        adjustedUserPostsData =
            { currentUserPostsData
                | posts =
                    if liked then
                        Post.setPostLikedInList postId currentUserPostsData.posts

                    else
                        Post.setPostNotLikedInList postId currentUserPostsData.posts
            }
    in
    { model | postsData = adjustedPostsData, userPostsData = adjustedUserPostsData }


likeCreatedToMsg : String -> Result Http.Error value -> Msg
likeCreatedToMsg postId likeCreatedResult =
    case likeCreatedResult of
        Ok _ ->
            LikeCreationSucceeded postId

        Err error ->
            case error of
                Http.BadStatus status ->
                    -- Conflict means there already was a like, so act like nothing happened
                    if status == 409 then
                        LikeCreationSucceeded postId

                    else
                        LikeCreationFailed postId

                _ ->
                    LikeCreationSucceeded postId


likeDeletedToMsg : String -> Result Http.Error value -> Msg
likeDeletedToMsg postId likeRemovedResult =
    case likeRemovedResult of
        Ok _ ->
            LikeRemovalSucceeded postId

        Err _ ->
            LikeRemovalFailed postId


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        initialPage =
            routeUrl url

        ( page, cmd ) =
            case flags.authToken of
                Just token ->
                    case initialPage of
                        Home ->
                            ( initialPage, Api.getPosts Pagination.defaultPaginationData token Nothing postsToMsg )

                        UserPage userId ->
                            ( initialPage, Api.getPosts Pagination.defaultPaginationData token (Just userId) userPostsToMsg )

                        _ ->
                            ( initialPage, Cmd.none )

                Nothing ->
                    ( Login, Nav.pushUrl key "/login" )
    in
    ( { key = key
      , url = url
      , page = page
      , authToken = flags.authToken
      , loginData = Login.defaultLoginData
      , signupData = Login.defaultLoginData
      , postsData = Post.defaultPostsData
      , userPostsData = Post.defaultPostsData
      , newPost = Post.defaultNewPost
      }
    , cmd
    )


type Msg
    = LinkClicked Browser.UrlRequest
    | LoginMsg Login.LoginMsg
    | SignupMsg Login.LoginMsg
    | LoginResponse (Result Http.Error User.User)
    | UrlChanged Url.Url
    | TokenChangedInOtherTab (Maybe String)
    | NewPostsLoaded (List Post.Post)
    | NewUserPostsLoaded (List Post.Post)
    | PostsErrored
    | UserPostsErrored
    | PostAction Post.PostAction
    | LikeCreationFailed String
    | LikeCreationSucceeded String
    | LikeRemovalSucceeded String
    | LikeRemovalFailed String
    | NewPostAction Post.NewPostAction
    | NewPostCreationSucceeded Post.Post
    | NewPostCreationFailed
    | Logout


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                newPage =
                    routeUrl url
            in
            ( { model
                | url = url
                , page = newPage
                , userPostsData =
                    case newPage of
                        UserPage _ ->
                            Post.defaultPostsData

                        _ ->
                            model.userPostsData
              }
            , case model.authToken of
                Nothing ->
                    Cmd.none

                Just token ->
                    case newPage of
                        UserPage userId ->
                            Api.getPosts Post.defaultPostsData.pagination token (Just userId) userPostsToMsg

                        _ ->
                            Cmd.none
            )

        LoginMsg loginMsg ->
            case loginMsg of
                Login.Submit ->
                    let
                        loginData =
                            model.loginData
                    in
                    ( { model | loginData = { loginData | error = False } }
                    , Api.login model.loginData LoginResponse
                    )

                _ ->
                    ( { model | loginData = Login.update loginMsg model.loginData }
                    , Cmd.none
                    )

        LoginResponse result ->
            case result of
                Ok user ->
                    ( { model
                        | authToken = Just user.id
                        , loginData = Login.defaultLoginData
                        , signupData = Login.defaultLoginData
                        , postsData = Post.defaultPostsData
                        , userPostsData = Post.defaultPostsData
                      }
                    , Cmd.batch
                        [ storeToken user.id
                        , Nav.pushUrl model.key "/"
                        , Api.getPosts Pagination.defaultPaginationData user.id Nothing postsToMsg
                        ]
                    )

                Err _ ->
                    let
                        loginData =
                            model.loginData
                    in
                    ( { model | loginData = { loginData | error = True } }, Cmd.none )

        TokenChangedInOtherTab token ->
            ( { model | authToken = token }
            , case token of
                Nothing ->
                    Nav.pushUrl model.key "/login"

                Just _ ->
                    case model.page of
                        Login ->
                            Nav.pushUrl model.key "/"

                        _ ->
                            Cmd.none
            )

        Logout ->
            ( { model
                | authToken = Nothing
                , postsData = Post.defaultPostsData
                , userPostsData = Post.defaultPostsData
                , newPost = Post.defaultNewPost
              }
            , Cmd.batch [ removeToken (), Nav.pushUrl model.key "/login" ]
            )

        NewPostsLoaded newPosts ->
            let
                currentPostsData =
                    model.postsData
            in
            ( { model
                | postsData =
                    { currentPostsData
                        | posts = currentPostsData.posts ++ newPosts
                        , error = False
                        , pagination = Pagination.nextPaginationData currentPostsData.pagination
                    }
              }
            , Cmd.none
            )

        NewUserPostsLoaded newUserPosts ->
            let
                currentUserPostsData =
                    model.userPostsData
            in
            ( { model
                | userPostsData =
                    { currentUserPostsData
                        | posts = currentUserPostsData.posts ++ newUserPosts
                        , error = False
                        , pagination = Pagination.nextPaginationData currentUserPostsData.pagination
                    }
              }
            , Cmd.none
            )

        PostsErrored ->
            let
                currentPostsData =
                    model.postsData
            in
            ( { model | postsData = { currentPostsData | error = True } }, Cmd.none )

        UserPostsErrored ->
            let
                currentUserPostsData =
                    model.userPostsData
            in
            ( { model | userPostsData = { currentUserPostsData | error = True } }, Cmd.none )

        PostAction postAction ->
            let
                currentPostsData =
                    model.postsData

                currentUserPostsdata =
                    model.userPostsData
            in
            case model.authToken of
                Just token ->
                    case postAction of
                        Post.LoadMore ->
                            ( model
                            , Api.getPosts
                                (case model.page of
                                    UserPage _ ->
                                        currentUserPostsdata.pagination

                                    _ ->
                                        currentPostsData.pagination
                                )
                                token
                                (case model.page of
                                    UserPage userId ->
                                        Just userId

                                    _ ->
                                        Nothing
                                )
                                (case model.page of
                                    UserPage _ ->
                                        userPostsToMsg

                                    _ ->
                                        postsToMsg
                                )
                            )

                        Post.AddPostLike postId ->
                            ( withDifferentLikeStatus model postId True
                            , Api.createLike postId token (likeCreatedToMsg postId)
                            )

                        Post.RemovePostLike postId ->
                            ( withDifferentLikeStatus model postId False
                            , Api.deleteLike postId token (likeDeletedToMsg postId)
                            )

                        Post.UserClick userId ->
                            ( model
                            , Cmd.batch
                                [ Nav.pushUrl model.key ("/users/" ++ userId)
                                ]
                            )

                _ ->
                    ( model, Cmd.none )

        LikeCreationFailed postId ->
            ( withDifferentLikeStatus model postId False, Cmd.none )

        LikeCreationSucceeded _ ->
            ( model, Cmd.none )

        LikeRemovalFailed postId ->
            ( withDifferentLikeStatus model postId True, Cmd.none )

        LikeRemovalSucceeded _ ->
            ( model, Cmd.none )

        SignupMsg signupMsg ->
            case signupMsg of
                Login.Submit ->
                    let
                        signupData =
                            model.signupData
                    in
                    ( { model | signupData = { signupData | error = False } }
                    , Api.signup model.signupData LoginResponse
                    )

                _ ->
                    ( { model | signupData = Login.update signupMsg model.signupData }
                    , Cmd.none
                    )

        NewPostAction action ->
            case action of
                Post.ChangeNewPost newPostText ->
                    ( { model | newPost = newPostText }, Cmd.none )

                Post.SubmitNewPost ->
                    case model.authToken of
                        Just token ->
                            ( { model | newPost = Post.defaultNewPost }, Api.createPost model.newPost token newPostToMsg )

                        _ ->
                            ( model, Cmd.none )

        NewPostCreationSucceeded _ ->
            case model.authToken of
                Just token ->
                    ( { model | postsData = Post.defaultPostsData }
                    , Api.getPosts Pagination.defaultPaginationData token Nothing postsToMsg
                    )

                _ ->
                    ( model, Cmd.none )

        NewPostCreationFailed ->
            ( model, Cmd.none )


routeUrl : Url.Url -> Page
routeUrl url =
    Maybe.withDefault NotFound (Parser.parse routeParser url)


routeParser : Parser (Page -> c) c
routeParser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Login (Parser.s "login")
        , Parser.map UserPage (Parser.s "users" </> Parser.string)
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Twitter Clone"
    , body =
        [ H.div []
            [ H.h1 [] [ H.text "Twitter Clone" ]
            , viewPage model
            ]
        ]
    }


viewPage : Model -> Html Msg
viewPage model =
    case model.page of
        Home ->
            viewHome model

        Login ->
            H.div []
                [ Login.viewLogin "Login" model.loginData LoginMsg
                , Login.viewLogin "Signup" model.signupData SignupMsg
                ]

        UserPage _ ->
            viewUserPage model

        NotFound ->
            viewNotFound


viewHome : Model -> Html Msg
viewHome model =
    H.div []
        [ H.h2 [] [ H.text "Home" ], viewLogout, Post.viewPostEditor model.newPost NewPostAction, Post.viewPosts model.postsData.posts PostAction ]


viewNotFound : Html Msg
viewNotFound =
    H.div []
        [ H.h2 [] [ H.text "404 - Not Found" ] ]


viewLogout : Html Msg
viewLogout =
    H.div []
        [ H.button [ HE.onClick Logout ] [ H.text "Logout" ] ]


viewUserPage : { a | userPostsData : { b | posts : List Post.Post } } -> Html Msg
viewUserPage model =
    H.div []
        [ H.h2 [] [ H.text "User Page" ], viewLogout, Post.viewPosts model.userPostsData.posts PostAction ]
