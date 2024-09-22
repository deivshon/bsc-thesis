module Post exposing (..)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Models.Pagination as Pagination


type alias Post =
    { id : String
    , content : String
    , userId : String
    , createdAt : Int
    , likes : Int
    , likedByUser : Bool
    , username : String
    }


type alias PostsData =
    { posts : List Post
    , error : Bool
    , pagination : Pagination.PaginationData
    }


type PostAction
    = UsernameClick String
    | AddPostLike String
    | RemovePostLike String
    | LoadMore


defaultPostsData : PostsData
defaultPostsData =
    { posts = []
    , error = False
    , pagination = Pagination.defaultPaginationData
    }


postDecoder : JD.Decoder Post
postDecoder =
    JD.map7 Post
        (JD.field "id" JD.string)
        (JD.field "content" JD.string)
        (JD.field "userId" JD.string)
        (JD.field "createdAt" JD.int)
        (JD.field "likes" JD.int)
        (JD.field "likedByUser" JD.bool)
        (JD.field "username" JD.string)


postListDecoder : JD.Decoder (List Post)
postListDecoder =
    JD.list postDecoder


viewPost : Post -> (PostAction -> msg) -> H.Html msg
viewPost post onPostAction =
    H.div [ HA.class "post" ]
        [ H.button [ HE.onClick (onPostAction (UsernameClick post.userId)) ] [ H.text ("User: " ++ post.username) ]
        , H.span [] [ H.text post.content ]
        , H.span [] [ H.text ("Likes: " ++ String.fromInt post.likes) ]
        , H.button
            [ HE.onClick
                (onPostAction
                    (if post.likedByUser then
                        RemovePostLike post.id

                     else
                        AddPostLike post.id
                    )
                )
            ]
            [ H.text
                (if post.likedByUser then
                    "Remove like"

                 else
                    "Like"
                )
            ]
        ]


viewPosts : List Post -> (PostAction -> msg) -> H.Html msg
viewPosts posts onPostAction =
    H.div [ HA.class "posts-container" ]
        (List.map (\p -> viewPost p onPostAction) posts
            ++ [ H.button [ HE.onClick (onPostAction LoadMore) ] [ H.text "Load more" ] ]
        )
