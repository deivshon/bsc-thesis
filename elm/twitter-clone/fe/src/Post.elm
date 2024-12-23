module Post exposing (..)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Json.Encode as JE
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


type alias NewPost =
    { content : String
    }


type alias PostsData =
    { posts : List Post
    , error : Bool
    , pagination : Pagination.PaginationData
    }


setPostLikedInList : String -> List Post -> List Post
setPostLikedInList postId postList =
    List.map
        (\post ->
            if post.id == postId then
                { post | likedByUser = True, likes = post.likes + 1 }

            else
                post
        )
        postList


setPostNotLikedInList : String -> List Post -> List Post
setPostNotLikedInList postId postList =
    List.map
        (\post ->
            if post.id == postId then
                { post | likedByUser = False, likes = post.likes - 1 }

            else
                post
        )
        postList


type PostAction
    = UserClick String
    | AddPostLike String
    | RemovePostLike String
    | LoadMore


type NewPostAction
    = ChangeNewPost String
    | SubmitNewPost


defaultPostsData : PostsData
defaultPostsData =
    { posts = []
    , error = False
    , pagination = Pagination.defaultPaginationData
    }


defaultNewPost : String
defaultNewPost =
    ""


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


newPostEncoder : String -> JE.Value
newPostEncoder newPostText =
    JE.object [ ( "content", JE.string newPostText ) ]


postListDecoder : JD.Decoder (List Post)
postListDecoder =
    JD.list postDecoder


viewPost : Post -> (PostAction -> msg) -> H.Html msg
viewPost post onPostAction =
    H.div [ HA.class "post" ]
        [ H.button [ HE.onClick (onPostAction (UserClick post.userId)) ] [ H.text ("User: " ++ post.username) ]
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


viewPostEditor : String -> (NewPostAction -> msg) -> H.Html msg
viewPostEditor postText onNewPostAction =
    H.div []
        [ H.textarea [ HA.value postText, HE.onInput (\changedPostText -> onNewPostAction (ChangeNewPost changedPostText)) ] []
        , H.button [ HE.onClick (onNewPostAction SubmitNewPost) ] [ H.text "Submit new post" ]
        ]
