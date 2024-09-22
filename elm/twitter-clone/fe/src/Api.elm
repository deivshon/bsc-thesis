module Api exposing (..)

import Http
import Json.Decode as JD
import Login
import Models.Pagination as Pagination
import Post
import User


type alias ApiError =
    { error : String
    , code : String
    }


baseUrl : String
baseUrl =
    "http://localhost:3001"


withAuthHeader : String -> List Http.Header -> List Http.Header
withAuthHeader token headers =
    headers ++ [ Http.header "X-User-Header" token ]


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


getPosts : Pagination.PaginationData -> String -> (Result Http.Error (List Post.Post) -> msg) -> Cmd msg
getPosts pagination token toMsg =
    Http.request
        { method = "GET"
        , url = baseUrl ++ "/posts?skip=" ++ String.fromInt pagination.skip ++ "&limit=" ++ String.fromInt pagination.limit
        , expect = Http.expectJson toMsg Post.postListDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , headers = withAuthHeader token []
        }
