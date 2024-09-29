module Api exposing (..)

import Http
import Json.Decode as JD
import Like
import Login
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


signup : Login.LoginData -> (Result Http.Error User.User -> msg) -> Cmd msg
signup content toMsg =
    Http.post
        { url = "http://localhost:3001/users"
        , body = Http.jsonBody (Login.loginDataEncoder content)
        , expect = Http.expectJson toMsg User.userDecoder
        }


getPosts : { a | skip : Int, limit : Int } -> String -> Maybe String -> (Result Http.Error (List Post.Post) -> msg) -> Cmd msg
getPosts pagination token maybeUserId toMsg =
    Http.request
        { method = "GET"
        , url =
            baseUrl
                ++ "/posts?skip="
                ++ String.fromInt pagination.skip
                ++ "&limit="
                ++ String.fromInt pagination.limit
                ++ (case maybeUserId of
                        Just userId ->
                            "&userId=" ++ userId

                        Nothing ->
                            ""
                   )
        , expect = Http.expectJson toMsg Post.postListDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , headers = withAuthHeader token []
        }


createLike : String -> String -> (Result Http.Error () -> msg) -> Cmd msg
createLike postId token toMsg =
    Http.request
        { method = "POST"
        , url = baseUrl ++ "/likes"
        , expect = Http.expectWhatever toMsg
        , body = Http.jsonBody (Like.createLikeBodyEncoder postId)
        , timeout = Nothing
        , tracker = Nothing
        , headers = withAuthHeader token []
        }


deleteLike : String -> String -> (Result Http.Error () -> msg) -> Cmd msg
deleteLike postId token toMsg =
    Http.request
        { method = "DELETE"
        , url = baseUrl ++ "/likes?postId=" ++ postId
        , expect = Http.expectWhatever toMsg
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , headers = withAuthHeader token []
        }


createPost : String -> String -> (Result Http.Error Post.Post -> msg) -> Cmd msg
createPost newPostText token toMsg =
    Http.request
        { method = "POST"
        , url = baseUrl ++ "/posts"
        , expect = Http.expectJson toMsg Post.postDecoder
        , body = Http.jsonBody (Post.newPostEncoder newPostText)
        , timeout = Nothing
        , tracker = Nothing
        , headers = withAuthHeader token []
        }
