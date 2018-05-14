module Types exposing (..)

import Http
import Json.Decode.Pipeline as Pipeline
import Json.Decode as Decode
import Json.Encode as Encode


-- Story record is a single user story


type alias Story =
    { cover : String
    , created : String
    , description : String
    , likes : Likes
    , title : String
    , user : User
    }


storyDecoder : Decode.Decoder Story
storyDecoder =
    Pipeline.decode Story
        |> Pipeline.required "cover_url" Decode.string
        |> Pipeline.required "date_created" Decode.string
        |> Pipeline.optional "description" Decode.string ""
        |> Pipeline.optional "likes" likesDecoder []
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "user" userDecoder



-- Stories record is an alias to List Story


type alias Stories =
    List Story


storiesDecoder : Decode.Decoder Stories
storiesDecoder =
    Decode.list storyDecoder



-- Decoder for API endpoint


apiStoriesDecoder : Decode.Decoder Stories
apiStoriesDecoder =
    Decode.at [ "entries" ] storiesDecoder



-- User embed record


type alias User =
    { avatar : String -- only decode avatar circle
    , username : String
    }


userDecoder : Decode.Decoder User
userDecoder =
    Pipeline.decode User
        |> Pipeline.optionalAt [ "avatar", "urls", "circle" ] Decode.string ""
        |> Pipeline.required "username" Decode.string



-- Like embed record


type alias Like =
    { date : String
    , user : String
    }


likeDecoder : Decode.Decoder Like
likeDecoder =
    Decode.map2 Like
        (Decode.at [ "date" ] Decode.string)
        (Decode.at [ "user" ] Decode.string)



-- Likes alias to List Like


type alias Likes =
    List Like


likesDecoder : Decode.Decoder Likes
likesDecoder =
    Decode.list likeDecoder
