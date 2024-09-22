module Home exposing (..)

import Post


type alias HomeData =
    { posts : List Post.Post
    , loading : Bool
    }


defaultHomeData : HomeData
defaultHomeData =
    { posts = []
    , loading = False
    }
