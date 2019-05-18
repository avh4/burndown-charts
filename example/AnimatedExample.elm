module Main exposing (main)

import Browser
import BurndownChart
import Date exposing (Date)
import Html exposing (Html)
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
                ( ( 2019, Apr, 9 ), 8 )

            else if Date.compare model.date (Date.fromCalendarDate 2019 Apr 17) == LT then
                ( ( 2019, Apr, 16 ), 24 )

            else
                ( ( 2019, Apr, 17 ), 24 )
    in
    { name = "MVP"
    , color = Just BurndownChart.blue
    , startDate = ( 2019, Apr, 9 )
    , targetDate = ( 2019, May, 14 )
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


type Msg
    = Tick


update : Msg -> Model -> Model
update msg model =
    case msg of
        Tick ->
            { model
                | day = model.day + 1
                , date =
                    if Date.weekday model.date == Time.Fri then
                        Date.add Date.Days 3 model.date

                    else
                        Date.add Date.Days 1 model.date
            }


main : Program () Model Msg
main =
    Browser.element
        { init =
            \() ->
                ( { day = 1
                  , date = Date.fromCalendarDate 2019 Apr 9
                  }
                , Cmd.none
                )
        , update =
            \msg model ->
                ( update msg model
                , Cmd.none
                )
        , subscriptions =
            \model ->
                Time.every 800 (always Tick)
        , view =
            \model ->
                BurndownChart.view
                    (chartConfig model)
        }
