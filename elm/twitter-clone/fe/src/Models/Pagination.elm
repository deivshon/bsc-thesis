module Models.Pagination exposing (..)


type alias PaginationData =
    { skip : Int
    , limit : Int
    }


defaultPaginationData : PaginationData
defaultPaginationData =
    { skip = 0
    , limit = 10
    }


nextPaginationData : PaginationData -> PaginationData
nextPaginationData paginationData =
    { paginationData | skip = paginationData.skip + 10 }
