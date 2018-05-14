port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, on, targetValue)
import Http
import Json.Decode.Pipeline as Pipeline
import Json.Decode as Decode
import Json.Encode as Encode
import Types


-- main app entry


main : Program Never Model Msg
main =
    Html.program
        { init = ( initModel, getUserStories )
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }



-- Sorting union types for choosing sorting method


type Sorting
    = ByTime -- descending order
    | ByLikes -- most likes first
    | ByTitle -- title in alphabetical order



-- Model record definition


type alias Model =
    { stories : Types.Stories
    , story : Maybe Types.Story
    , search : String
    , sorting : Sorting
    , loading : Bool
    , success : String
    , error : String
    }



-- initModel instantiate an empty Model


initModel : Model
initModel =
    Model [] Nothing "" ByTime True "" ""



-- Msg union type for user actions


type Msg
    = NoOp
    | GetStories
    | GotStories (Result Http.Error Types.Stories)
    | SearchWith String
    | SortWith Sorting
    | SelectStory Types.Story


apiEndpoint : String
apiEndpoint =
    "http://api.kano.me/share?limit=100"


getUserStories : Cmd Msg
getUserStories =
    let
        request =
            Http.get apiEndpoint Types.apiStoriesDecoder
    in
        Http.send GotStories request



-- update Model by Msg type


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model_ =
    let
        model =
            { model_
                | loading = False
                , success = ""
                , error = ""
            }
    in
        case msg of
            NoOp ->
                ( { model | story = Nothing }, Cmd.none )

            GetStories ->
                ( model, Cmd.none )

            GotStories (Ok stories) ->
                ( { model | stories = stories }, Cmd.none )

            GotStories (Err error) ->
                ( { model | error = toString error }
                , Cmd.none
                )

            SearchWith search ->
                ( { model | search = search }, Cmd.none )

            SortWith sorting ->
                ( { model | sorting = sorting }, Cmd.none )

            SelectStory story ->
                ( { model | story = Just story }, Cmd.none )



-- view is the main entry view rendering HTML


viewHeader : Model -> Html Msg
viewHeader model =
    div [ class "hero-head" ]
        [ div [ class "container has-text-centered nav-logo" ]
            [ a
                [ class "navbar-item logo-wrapper"
                , href "/"
                ]
                [ img
                    [ class <|
                        if model.story == Nothing then
                            "logo"
                        else
                            "logo-details"
                    , src "http://dl.kano.me/tech-test/Logo.svg"
                    ]
                    []
                ]
            ]
        ]


viewMenu : Model -> Html Msg
viewMenu model =
    div [ class "hero-body is-medium" ]
        [ div [ class "container has-text-centered" ]
            [ p [ class "title" ] [ text "Latest 100" ]
            ]
        ]


isActiveSorting : Sorting -> Model -> Attribute Msg
isActiveSorting sorting model =
    if sorting == model.sorting then
        class "is-active"
    else
        onClick <| SortWith sorting


viewSortControl : Model -> Html Msg
viewSortControl model =
    div [ class "container" ]
        [ ul []
            [ li [ isActiveSorting ByTime model ] [ a [] [ text "Time" ] ]
            , li [ isActiveSorting ByLikes model ] [ a [] [ text "Likes" ] ]
            , li [ isActiveSorting ByTitle model ] [ a [] [ text "Title" ] ]
            ]
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    div [ class "hero-foot" ]
        [ nav [ class "tabs is-boxed is-fullwidth is-hidden-tablet" ]
            [ viewSortControl model ]
        ]


viewControl : Model -> Html Msg
viewControl model =
    div [ class "container" ]
        [ div [ class "columns is-mobile" ]
            [ div [ class "column is-12-mobile is-size-6-mobile is-4-tablet" ]
                [ div [ class "field is-small" ]
                    [ p [ class "control has-icons-left" ]
                        [ input
                            [ class "input"
                            , type_ "text"
                            , placeholder "Search title"
                            , onInput SearchWith
                            , value model.search
                            ]
                            []
                        , span [ class "icon is-small is-left" ]
                            [ i [ class "fa fa-search" ] [] ]
                        ]
                    ]
                ]
            , div [ class "column is-hidden-mobile is-offset-2 is-6-tablet" ]
                [ nav [ class "tabs is-fullwidth is-hidden-mobile" ]
                    [ viewSortControl model ]
                ]
            ]
        ]


viewStory : Types.Story -> Html Msg
viewStory story =
    div [ class "column is-12-mobile is-6-tablet is-4-desktop" ]
        [ div
            [ class "card"
            , onClick <| SelectStory story
            ]
            [ div [ class "card-image is-boxed" ]
                [ figure [ class "image is-4by3" ]
                    [ img [ src story.cover ] [] ]
                ]
            , div [ class "card-content" ]
                [ div [ class "title" ]
                    [ text story.title ]
                , div [ class "subtitle has-text-grey-light" ]
                    [ text story.user.username ]
                , div [ class "is-size-7 has-text-grey-light" ]
                    [ span [ class "icon is-small is-left" ]
                        [ img
                            [ class "hear"
                            , src "http://dl.kano.me/tech-test/KANO-ICONS-HEART.svg"
                            ]
                            []
                        ]
                    , text <| (toString <| List.length story.likes) ++ " likes"
                    ]
                ]
            ]
        ]


viewStories : Model -> Html Msg
viewStories model =
    let
        stories =
            filterAndSort model.search model.sorting model.stories
    in
        case List.length stories > 0 of
            True ->
                div [ class "cards columns is-mobile" ]
                    (List.map viewStory stories)

            False ->
                div [ class "container subtitle has-text-centered" ]
                    [ text <|
                        if model.loading then
                            "Loading, please wait..."
                        else
                            "No results found. Please try another search"
                    ]


viewBackLink : Html Msg
viewBackLink =
    a
        [ class "back-link"
        , onClick NoOp
        ]
        [ span
            [ class "icon is-left" ]
            [ img
                [ class "left-arrow"
                , src "http://dl.kano.me/tech-test/KANO-ICONS-ARROW.svg"
                ]
                []
            ]
        , span [ class "details is-size-7" ] [ text " GO BACK" ]
        ]


viewStoryDetails : Types.Story -> Html Msg
viewStoryDetails story =
    section [ class "hero is-medium" ]
        [ div [ class "columns is-mobile" ]
            [ div [ class "column is-offset-8 is-2" ]
                [ div [ class "likes-wrapper" ]
                    [ img
                        [ class "pink-heart"
                        , src "http://dl.kano.me/tech-test/KANO-ICONS-HEART.svg"
                        , class "image is-24x24"
                        ]
                        []
                    , br [] []
                    , span [ class "icon likes-count" ]
                        [ text <| toString <| List.length story.likes ]
                    ]
                ]
            ]
        , div [ class "columns" ]
            [ div [ class "column is-offset-2 is-8-tablet" ]
                [ div [ class "avatar-wrapper" ]
                    [ img
                        [ class "avatar"
                        , src story.user.avatar
                        , class "image is-48x48"
                        ]
                        []
                    ]
                , div [ class "has-black-text is-size-6" ]
                    [ text story.title ]
                , strong [ class "has-grey-text is-size-7" ]
                    [ text <| "by " ++ story.user.username ]
                , p [ class "has-grey-text is-size-7" ]
                    [ text story.description ]
                ]
            ]
        ]


filterAndSort : String -> Sorting -> Types.Stories -> Types.Stories
filterAndSort search sorting stories =
    let
        filtered =
            stories
                |> List.filter (\s -> String.contains search s.title)
    in
        case sorting of
            ByTime ->
                -- descending order
                filtered
                    |> List.sortBy .created
                    |> List.reverse

            ByLikes ->
                -- descending order by length of likes
                filtered
                    |> List.sortBy (\s -> List.length s.likes)
                    |> List.reverse

            ByTitle ->
                -- alphabetically
                List.sortBy .title filtered


view : Model -> Html Msg
view model =
    section []
        (case model.story of
            Nothing ->
                [ section [ class "hero is-info is-medium" ]
                    [ viewHeader model
                    , viewMenu model
                    , viewFooter model
                    ]
                , viewControl model
                , viewStories model
                ]

            Just story ->
                [ section [ class "hero is-danger has-text-centered is-medium" ]
                    [ viewHeader model
                    , viewBackLink
                    , div [ class "hero-body" ]
                        [ div [ class "container" ]
                            [ img [ src story.cover ] []
                            ]
                        ]
                    ]
                , viewStoryDetails story
                ]
        )
