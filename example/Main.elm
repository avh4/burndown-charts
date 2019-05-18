module Main exposing (main)

import BurndownChart
import Date
import Html exposing (Html)
import LineChart.Colors as Colors
import Time


chartConfig : BurndownChart.Config
chartConfig =
    { name = "MVP"
    , color = Just Colors.blue
    , pointsRemaining = [ 8, 8, 7, 7, 7, 24, 24, 24, 24, 24, 21, 21, 20, 22, 22, 14, 12, 11, 11, 11, 10, 8, 8, 8, 8, 8, 8, 7, 1 ]
    , startDate = Date.fromCalendarDate 2019 Time.Apr 9
    , targetDate = Date.fromCalendarDate 2019 Time.May 14
    , baseline = ( Date.fromCalendarDate 2019 Time.Apr 17, 24 )
    , milestones =
        [ ( "🐣", 21, Just (Date.fromCalendarDate 2019 Time.Apr 23) )
        , ( "📝", 14, Just (Date.fromCalendarDate 2019 Time.Apr 30) )
        , ( "\u{1F57A}", 12, Just (Date.fromCalendarDate 2019 Time.May 1) )
        , ( "🏛", 0, Nothing )
        ]
    }


main : Html msg
main =
    BurndownChart.view chartConfig
