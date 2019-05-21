module Main exposing (main)

import Browser
import BurndownChart
import Date exposing (Date)
import Html exposing (Html)
import Html.Attributes exposing (class, id, style)
import Time exposing (Month(..))


chartConfig : Model -> BurndownChart.Config
chartConfig model =
    let
        at ( y, m, d ) =
            if Date.compare model.date (Date.fromCalendarDate y m d) == LT then
                Nothing

            else
                Just ( y, m, d )

        baseline =
            if Date.compare model.date (Date.fromCalendarDate 2019 Apr 16) == LT then
                BurndownChart.timeBased ( 2019, Apr, 9 ) ( 2019, May, 14 )

            else if Date.compare model.date (Date.fromCalendarDate 2019 Apr 17) == LT then
                BurndownChart.timeBased ( 2019, Apr, 16 ) ( 2019, May, 14 )

            else
                BurndownChart.timeBased ( 2019, Apr, 17 ) ( 2019, May, 14 )
    in
    { name = "MVP"
    , color = Just BurndownChart.blue
    , startDate = ( 2019, Apr, 9 )
    , baseline = baseline
    , milestones =
        [ ( "🐣", 21, at ( 2019, Apr, 23 ) )
        , ( "📝", 14, at ( 2019, Apr, 30 ) )
        , ( "\u{1F57A}", 12, at ( 2019, May, 1 ) )
        , ( "🏛", 0, at ( 2019, May, 20 ) )
        ]
    , pointsRemaining =
        [ 8, 8, 7, 7, 7, 24, 24, 24, 24, 24, 21, 21, 20, 22, 22, 14, 12, 11, 11, 11, 10, 8, 8, 8, 8, 8, 8, 7, 1, 0 ]
            |> List.take model.day
    }


type alias Model =
    { day : Int
    , date : Date
    }


inc : Model -> Model
inc model =
    { model
        | day = model.day + 1
        , date =
            if Date.weekday model.date == Time.Fri then
                Date.add Date.Days 3 model.date

            else
                Date.add Date.Days 1 model.date
    }


main : Html msg
main =
    Html.div [] <|
        List.concat
            [ [ screenshot "basic"
                    [ BurndownChart.view
                        { name = ""
                        , color = Nothing
                        , startDate = ( 2019, Apr, 9 )
                        , baseline = BurndownChart.timeBased ( 2019, Apr, 9 ) ( 2019, May, 14 )
                        , milestones = []
                        , pointsRemaining = [ 8 ]
                        }
                    ]
              ]
            , [ screenshot "updated-points"
                    [ BurndownChart.view
                        { name = ""
                        , color = Nothing
                        , startDate = ( 2019, Apr, 9 )
                        , baseline = BurndownChart.timeBased ( 2019, Apr, 9 ) ( 2019, May, 14 )
                        , milestones = []
                        , pointsRemaining = [ 8, 8, 7 ]
                        }
                    ]
              ]
            , [ screenshot "milestones"
                    [ BurndownChart.view
                        { name = ""
                        , color = Nothing
                        , startDate = ( 2019, Apr, 9 )
                        , baseline = BurndownChart.timeBased ( 2019, Apr, 9 ) ( 2019, May, 14 )
                        , milestones =
                            [ ( "🐣", 6, Just ( 2019, Apr, 22 ) )
                            , ( "\u{1F57A}", 3, Nothing )
                            ]
                        , pointsRemaining = [ 8, 8, 7, 7, 8, 8, 7, 7, 7, 6, 5, 5 ]
                        }
                    ]
              ]
            , let
                step model acc =
                    if model.day >= 31 then
                        acc

                    else
                        step (inc model)
                            (screenshot ("screenshot-" ++ String.fromInt model.day) [ BurndownChart.view (chartConfig model) ] :: acc)
              in
              step { day = 1, date = Date.fromCalendarDate 2019 Apr 9 } []
                |> List.reverse
            ]


screenshot : String -> List (Html msg) -> Html msg
screenshot name =
    Html.div
        [ class "screenshot"
        , id name
        , style "display" "inline-block"
        ]
