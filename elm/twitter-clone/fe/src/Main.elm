module Main exposing (main)

import Api
import Browser
import Browser.Navigation as Nav
import Html as H exposing (Html)
import Html.Events as HE
import Http
import Login
import Ports exposing (noInteractionTokenChange, removeToken, storeToken)
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
    }


type Page
    = Login
    | Home
    | NotFound


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        initialPage =
            routeUrl url

        ( page, cmd ) =
            case flags.authToken of
                Just _ ->
                    ( initialPage, Cmd.none )

                Nothing ->
                    ( Login, Nav.pushUrl key "/login" )
    in
    ( { key = key
      , url = url
      , page = page
      , authToken = flags.authToken
      , loginData = Login.defaultLoginData
      }
    , cmd
    )


type Msg
    = LinkClicked Browser.UrlRequest
    | LoginMsg Login.LoginMsg
    | LoginResponse (Result Http.Error User.User)
    | UrlChanged Url.Url
    | TokenChangedInOtherTab (Maybe String)
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
            ( { model | url = url, page = routeUrl url }
            , Cmd.none
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
                    ( { model | authToken = Just user.id, loginData = Login.defaultLoginData }
                    , Cmd.batch
                        [ storeToken user.id
                        , Nav.pushUrl model.key "/"
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
            ( { model | authToken = Nothing }, Cmd.batch [ removeToken (), Nav.pushUrl model.key "/login" ] )


routeUrl : Url.Url -> Page
routeUrl url =
    Maybe.withDefault NotFound (Parser.parse routeParser url)


routeParser : Parser (Page -> c) c
routeParser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Login (Parser.s "login")
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
            viewHome

        Login ->
            Login.viewLogin model.loginData LoginMsg

        NotFound ->
            viewNotFound


viewHome : Html Msg
viewHome =
    H.div []
        [ H.h2 [] [ H.text "Home" ], viewLogout ]


viewNotFound : Html Msg
viewNotFound =
    H.div []
        [ H.h2 [] [ H.text "404 - Not Found" ] ]


viewLogout : Html Msg
viewLogout =
    H.div []
        [ H.button [ HE.onClick Logout ] [ H.text "Logout" ] ]