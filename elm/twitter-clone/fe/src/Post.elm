module Post exposing (..)

import Html as H
import Json.Decode as JD
import Models.Pagination as Pagination


type alias Post =
    { id : String
    , content : String
    , userId : String
    , createdAt : Int
    , likes : Int
    , likedByUser : Bool
    }


type alias PostsData =
    { posts : List Post
    , error : Bool
    , pagination : Pagination.PaginationData
    }


defaultPostsData : PostsData
defaultPostsData =
    { posts = []
    , error = False
    , pagination = Pagination.defaultPaginationData
    }


postDecoder : JD.Decoder Post
postDecoder =
    JD.map6 Post
        (JD.field "id" JD.string)
        (JD.field "content" JD.string)
        (JD.field "userId" JD.string)
        (JD.field "createdAt" JD.int)
        (JD.field "likes" JD.int)
        (JD.field "likedByUser" JD.bool)


postListDecoder : JD.Decoder (List Post)
postListDecoder =
    JD.list postDecoder


viewPost : Post -> H.Html msg
viewPost post =
    H.div []
        [ H.text post.content
        ]


viewPosts : List Post -> H.Html msg
viewPosts posts =
    H.div []
        (List.map viewPost posts)
