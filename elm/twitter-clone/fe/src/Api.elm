module Api exposing (..)

import Http
import Json.Decode as JD
import Login
import User


type alias ApiError =
    { error : String
    , code : String
    }


apiErrorDecoder : JD.Decoder ApiError
apiErrorDecoder =
    JD.map2 ApiError
        (JD.field "error" JD.string)
        (JD.field "code" JD.string)


login : Login.LoginData -> (Result Http.Error User.User -> msg) -> Cmd msg
login content toMsg =
    Http.post
        { url = "http://localhost:3001/auth/login"
        , body = Http.jsonBody (Login.loginDataEncoder content)
        , expect = Http.expectJson toMsg User.userDecoder
        }
