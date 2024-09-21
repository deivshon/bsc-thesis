module Login exposing (..)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Encode as JE


type alias LoginData =
    { username : String
    , password : String
    , error : Bool
    }


loginDataEncoder : LoginData -> JE.Value
loginDataEncoder loginData =
    JE.object
        [ ( "username", JE.string loginData.username )
        , ( "password", JE.string loginData.password )
        ]


defaultLoginData : LoginData
defaultLoginData =
    { username = ""
    , password = ""
    , error = False
    }


type LoginMsg
    = UsernameChange String
    | PasswordChange String
    | Submit


update : LoginMsg -> LoginData -> LoginData
update msg loginData =
    case msg of
        UsernameChange username ->
            { loginData | username = username }

        PasswordChange password ->
            { loginData | password = password }

        Submit ->
            loginData


viewLogin : { a | username : String, password : String, error : Bool } -> (LoginMsg -> msg) -> H.Html msg
viewLogin loginData onAction =
    H.div []
        [ H.h1 [] [ H.text "Login" ]
        , H.form [ HE.onSubmit (onAction Submit) ]
            [ H.input [ HA.type_ "text", HA.placeholder "Username", HA.value loginData.username, HE.onInput (\username -> onAction (UsernameChange username)) ] []
            , H.input [ HA.type_ "password", HA.placeholder "Password", HA.value loginData.password, HE.onInput (\password -> onAction (PasswordChange password)) ] []
            , H.button [ HA.type_ "submit" ] [ H.text "Login" ]
            ]
        , H.div []
            [ H.text
                (if loginData.error then
                    "Error"

                 else
                    ""
                )
            ]
        ]
