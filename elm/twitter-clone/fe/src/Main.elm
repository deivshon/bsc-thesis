module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , page : Page
    , authToken : Maybe String
    }


type Page
    = Login
    | Home
    | NotFound


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        page =
            routeUrl url
    in
    -- TODO - get token from local storage
    ( Model key url page Nothing, Cmd.none )


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


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
        [ div []
            [ h1 [] [ text "Twitter Clone" ]
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
            viewLogin

        NotFound ->
            viewNotFound


viewHome : Html Msg
viewHome =
    div []
        [ h2 [] [ text "Home" ] ]


viewNotFound : Html Msg
viewNotFound =
    div []
        [ h2 [] [ text "404 - Not Found" ] ]


viewLogin : Html Msg
viewLogin =
    div [] [ text "Login" ]
