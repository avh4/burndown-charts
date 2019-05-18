module Main exposing (main)

import BurndownChart
import Html exposing (Html)
import Time exposing (Month(..))


chartConfig : BurndownChart.Config
chartConfig =
    { name = "MVP"
    , color = Just BurndownChart.blue
    , pointsRemaining = [ 8, 8, 7, 7, 7, 24, 24, 24, 24, 24, 21, 21, 20, 22, 22, 14, 12, 11, 11, 11, 10, 8, 8, 8, 8, 8, 8, 7, 1 ]
    , startDate = ( 2019, Apr, 9 )
    , targetDate = ( 2019, May, 14 )
    , baseline = ( ( 2019, Apr, 17 ), 24 )
    , milestones =
        [ ( "🐣", 21, Just ( 2019, Apr, 23 ) )
        , ( "📝", 14, Just ( 2019, Apr, 30 ) )
        , ( "\u{1F57A}", 12, Just ( 2019, May, 1 ) )
        , ( "🏛", 0, Nothing )
        ]
    }


main : Html msg
main =
    BurndownChart.view chartConfig
