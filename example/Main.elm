module Main exposing (main)

import BurndownChart
import Html exposing (Html)
import Time exposing (Month(..))


chartConfig : BurndownChart.Config
chartConfig =
    { name = "MVP"
    , color = Just BurndownChart.blue
    , startDate = ( 2019, Apr, 9 )
    , baseline =
        ( ( 2019, Apr, 17 )
        , BurndownChart.targetDate ( 2019, May, 14 )
        )
    , milestones =
        [ ( "🐣", 21, Just ( 2019, Apr, 23 ) )
        , ( "📝", 14, Just ( 2019, Apr, 30 ) )
        , ( "\u{1F57A}", 12, Just ( 2019, May, 1 ) )
        , ( "🏛", 0, Nothing )
        ]
    , pointsRemaining = [ 8, 8, 7, 7, 7, 24, 24, 24, 24, 24, 21, 21, 20, 22, 22, 14, 12, 11, 11, 11, 10, 8, 8, 8, 8, 8, 8, 7, 1 ]
    }


scopeBasedExample : BurndownChart.Config
scopeBasedExample =
    { name = "MVP"
    , color = Just BurndownChart.gold
    , startDate = ( 2019, May, 17 )
    , baseline =
        ( ( 2019, May, 17 )
        , BurndownChart.estimatedVelocity 7.5
        )
    , milestones =
        [ ( "👩\u{200D}🎨", 17, Nothing )
        , ( "📐", 8, Nothing )
        , ( "🔍", 0, Nothing )
        ]
    , pointsRemaining = [ 34, 38, 38, 35, 35, 32 ]
    }


main : Html msg
main =
    Html.div []
        [ BurndownChart.view chartConfig
        , BurndownChart.view scopeBasedExample
        ]
