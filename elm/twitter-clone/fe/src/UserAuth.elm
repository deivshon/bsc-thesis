module UserAuth exposing (..)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Encode as JE


type alias UserAuthData =
    { username : String
    , password : String
    , error : Bool
    }


userAuthDataEncoder : UserAuthData -> JE.Value
userAuthDataEncoder userAuthData =
    JE.object
        [ ( "username", JE.string userAuthData.username )
        , ( "password", JE.string userAuthData.password )
        ]


defaultUserAuthData : UserAuthData
defaultUserAuthData =
    { username = ""
    , password = ""
    , error = False
    }


type UserAuthMsg
    = UsernameChange String
    | PasswordChange String
    | Submit


update : UserAuthMsg -> UserAuthData -> UserAuthData
update msg userAuthData =
    case msg of
        UsernameChange username ->
            { userAuthData | username = username }

        PasswordChange password ->
            { userAuthData | password = password }

        Submit ->
            userAuthData


viewUserAuthForm : String -> UserAuthData -> (UserAuthMsg -> msg) -> H.Html msg
viewUserAuthForm label userAuthData onAction =
    H.div []
        [ H.h1 [] [ H.text label ]
        , H.form [ HE.onSubmit (onAction Submit) ]
            [ H.input [ HA.type_ "text", HA.placeholder "Username", HA.value userAuthData.username, HE.onInput (\username -> onAction (UsernameChange username)) ] []
            , H.input [ HA.type_ "password", HA.placeholder "Password", HA.value userAuthData.password, HE.onInput (\password -> onAction (PasswordChange password)) ] []
            , H.button [ HA.type_ "submit" ] [ H.text label ]
            ]
        , H.div []
            [ H.text
                (if userAuthData.error then
                    "Error"

                 else
                    ""
                )
            ]
        ]
