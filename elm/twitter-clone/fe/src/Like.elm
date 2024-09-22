module Like exposing (..)

import Json.Encode as JE


type alias CreateLikeBody =
    { postId : String
    }


createLikeBodyEncoder : String -> JE.Value
createLikeBodyEncoder postId =
    JE.object [ ( "postId", JE.string postId ) ]
