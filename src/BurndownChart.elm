module BurndownChart exposing (Config, view)

{-|

@docs Config, view

-}

import Color exposing (Color)
import Date exposing (Date)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Range as Range
import LineChart.Axis.Tick as Tick
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Title as Title
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line
import Svg
import Svg.Attributes
import Time


{-|

  - `name`: The name of the project. This will be used as the title of the chart.
  - `color`: The color used for the burndown line. If not given, this will use the default color from `terezka/line-charts`.
  - `startDate`: The start date of the project.
  - `targetDate`: The planned release date for the project. (If your project is scope-based, use your current velocity to estimate a target date.)
  - `baseline`: The most recent date on which the scope of the project was set and the number of points estimated to be in scope at that time. This is used along with the `targetDate` to draw the goal line.
  - `milestones`: (optional) A list of intermediate milestones to draw on the chart. Each milestone includes:
      - The name of the milestone (consider using a single-character emoji for this!)
      - The number of points that will remain in the project after this milestone is completed
      - The date the milestone we delivered, or `Nothing` if it has not been delivered yet.
  - `pointsRemaining`: A list containing the number of points remaining at the start of each day of the project.

-}
type alias Config =
    { name : String
    , color : Maybe Color
    , startDate : Date
    , targetDate : Date
    , baseline : ( Date, Int )
    , milestones : List ( String, Int, Maybe Date )
    , pointsRemaining : List Int
    }


{-| **Show a burndown chart**
-}
view : Config -> Html msg
view model =
    let
        maxX =
            max
                (dateToX model.startDate model.targetDate)
                (List.length model.pointsRemaining)
    in
    LineChart.viewCustom
        { y =
            Axis.custom
                { title = Title.default "Points remaining"
                , variable = Just << Tuple.second
                , pixels = 400
                , range = Range.custom (\range -> { range | min = 0, max = max range.max 25 })
                , axisLine = AxisLine.full Colors.gray
                , ticks = Ticks.int 12
                }
        , x =
            Axis.custom
                { title = Title.default "Date"
                , variable = Just << toFloat << Tuple.first
                , pixels = 220 + 27 * maxX
                , range = Range.custom (\range -> { range | max = toFloat maxX })
                , axisLine = AxisLine.full Colors.gray
                , ticks =
                    Ticks.intCustom maxX <|
                        \i ->
                            let
                                offset =
                                    Date.weekdayNumber model.startDate

                                day =
                                    model.startDate
                                        |> Date.add Date.Days i
                                        |> Date.add Date.Days (2 * ((i + offset - 1) // 5))

                                label =
                                    if Date.weekdayNumber day == 1 then
                                        Date.format "M/d" day

                                    else
                                        Date.format "E" day |> String.left 0
                            in
                            Tick.custom
                                { position = toFloat i
                                , color = Colors.gray
                                , width = 1
                                , length = 5
                                , grid = True
                                , direction = Tick.negative
                                , label =
                                    Just <|
                                        Svg.text_
                                            []
                                            [ Svg.tspan [] [ Svg.text label ] ]
                                }
                }
        , container = Container.default "line-chart-1"
        , interpolation = Interpolation.default
        , intersection = Intersection.default
        , legends = Legends.default
        , events = Events.default
        , junk =
            Junk.custom <|
                \system ->
                    let
                        viewRelease ( name, points, released ) =
                            let
                                baselinePoints =
                                    Tuple.second model.baseline

                                day =
                                    case released of
                                        Just d ->
                                            dateToX model.startDate d

                                        Nothing ->
                                            dateToX model.startDate (Tuple.first model.baseline)
                                                + ceiling
                                                    (toFloat (baselinePoints - points)
                                                        / toFloat baselinePoints
                                                        * toFloat (dateToX model.startDate model.targetDate - dateToX model.startDate (Tuple.first model.baseline))
                                                    )

                                isReleased =
                                    released /= Nothing

                                lineStyle =
                                    if isReleased then
                                        []

                                    else
                                        [ Svg.Attributes.strokeDasharray "4 4" ]

                                label =
                                    if isReleased then
                                        "🏁 " ++ name

                                    else
                                        name

                                x =
                                    toFloat day

                                y =
                                    toFloat points
                            in
                            [ Junk.vertical system lineStyle x

                            --                        , Junk.horizontal system [] y
                            --                        , Junk.circle system 8 Colors.red x y
                            , Junk.labelAt system x y -7 0 "left" Colors.red label
                            ]
                    in
                    { below =
                        List.concatMap viewRelease model.milestones
                    , above = []
                    , html = []
                    }
        , grid = Grid.default
        , area = Area.default
        , line = Line.default
        , dots = Dots.default
        }
        [ LineChart.dash Colors.gray
            Dots.none
            "Goal"
            [ 4, 4 ]
            [ ( dateToX model.startDate (Tuple.first model.baseline), toFloat <| Tuple.second model.baseline )
            , ( dateToX model.startDate model.targetDate, 0 )
            ]
        , LineChart.line (model.color |> Maybe.withDefault Colors.pink) Dots.circle "Actual" (List.indexedMap (\i x -> ( i, toFloat x )) model.pointsRemaining)
        ]


dateToX : Date -> Date -> Int
dateToX startDate date =
    let
        startMonday =
            Date.fromWeekDate
                (Date.year startDate)
                (Date.weekNumber startDate)
                Time.Mon
    in
    Date.diff Date.Days startDate date
        - (2 * Date.diff Date.Weeks startMonday date)