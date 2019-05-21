module BurndownChart exposing
    ( view, Date, Config
    , EstimationMethod, estimatedVelocity, targetDate
    , red, pink, gold, green, teal, cyan, blue, purple
    )

{-|


## Burndown charts

@docs view, Date, Config


## Estimation method

@docs EstimationMethod, estimatedVelocity, targetDate


## Colors

These are the basic colors available in `terezka/line-charts` exposed here for convenience so you don't have to add `line-charts` as a direct dependency.

If you want other colors, you can use colors from [`LineCharts.Colors`](https://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Colors),
any color you can create with [`avh4/elm-color`](https://package.elm-lang.org/packages/avh4/elm-color/latest),
or colors from any other package that produces a [`Color`](https://package.elm-lang.org/packages/avh4/elm-color/latest/Color).

@docs red, pink, gold, green, teal, cyan, blue, purple

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
  - `baseline`: A baseline estimate for the project. This is a tuple containing:
      - The date on which the baseline was set (typically this will be the same as the project start date).
      - The [`EstimationMethod`](#EstimationMethod) to use to calculate the goal line.
  - `milestones`: (optional) A list of intermediate milestones to draw on the chart. Each milestone includes:
      - The name of the milestone (consider using a single-character emoji for this!)
      - The number of points that will remain in the project after this milestone is completed
      - The date the milestone was accepted, or `Nothing` if it has not been accepted yet.
  - `pointsRemaining`: A list containing the number of points remaining at the start of each day of the project.

-}
type alias Config =
    { name : String
    , color : Maybe Color
    , startDate : Date
    , baseline : ( Date, EstimationMethod )
    , milestones : List ( String, Int, Maybe Date )
    , pointsRemaining : List Int
    }


{-| (year, month, day)
-}
type alias Date =
    ( Int, Time.Month, Int )


{-| A burndown chart shows a baseline (or goal line) starting from the baseline date
with the number of points remaining on that date to the estimated end date
(with the slope of the line beind the estimated velocity).

You can specify the target date (a time-based estimate) and have the estimated velocity be calculated;
or you can specify the estimated velocity (a scope-based estimate) and have the target date be calculated.

-}
type EstimationMethod
    = TargetDate Date
    | EstimatedVelocity Float


{-| A time-based estimate where the target date is specified and the estimated velocity will be calculated.
-}
targetDate : Date -> EstimationMethod
targetDate =
    TargetDate


{-| A scope-based estimate where the estimated velocity is specified and the target date will be calculated.
-}
estimatedVelocity : Float -> EstimationMethod
estimatedVelocity =
    EstimatedVelocity


{-| **Show a burndown chart**

See [`Config`](#Config).

-}
view : Config -> Html msg
view model =
    let
        baselineDate =
            Tuple.first model.baseline

        baselinePoints =
            List.drop (dateToX model.startDate baselineDate)
                model.pointsRemaining
                |> List.head
                |> Maybe.withDefault 0

        targetDateX =
            case Tuple.second model.baseline of
                TargetDate date ->
                    dateToX model.startDate date

                EstimatedVelocity velocity ->
                    let
                        daysPerIteration =
                            5
                    in
                    dateToX model.startDate baselineDate
                        + ceiling (toFloat baselinePoints / velocity * daysPerIteration)

        maxX =
            max targetDateX (List.length model.pointsRemaining)
    in
    LineChart.viewCustom
        { y =
            Axis.custom
                { title =
                    Title.custom
                        (\data axis -> axis.max)
                        0
                        0
                        (Svg.g
                            []
                            [ Svg.text_
                                [ Svg.Attributes.style "pointer-events: none;"
                                ]
                                [ Svg.tspan
                                    [ Svg.Attributes.x "0"
                                    , Svg.Attributes.y "-1.2em"
                                    ]
                                    [ Svg.text "Points " ]
                                , Svg.tspan
                                    [ Svg.Attributes.x "0"
                                    , Svg.Attributes.dy "1.2em"
                                    ]
                                    [ Svg.text "remaining" ]
                                ]
                            ]
                        )
                , variable = Just << Tuple.second
                , pixels = 400
                , range =
                    Range.custom
                        (\range ->
                            { range
                                | min = 0
                                , max = max range.max (toFloat <| baselinePoints) + 1
                            }
                        )
                , axisLine = AxisLine.full Colors.gray
                , ticks = Ticks.int 12
                }
        , x =
            Axis.custom
                { title = Title.default "Date"
                , variable = Just << toFloat << Tuple.first
                , pixels = 220 + 27 * maxX
                , range =
                    Range.custom
                        (\range ->
                            { range
                                | min = 0
                                , max = max range.max (toFloat maxX)
                            }
                        )
                , axisLine = AxisLine.full Colors.gray
                , ticks =
                    Ticks.intCustom maxX <|
                        \i ->
                            let
                                offset =
                                    Date.weekdayNumber (tupleToDate model.startDate)

                                day =
                                    tupleToDate model.startDate
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
                                day =
                                    case released of
                                        Just d ->
                                            dateToX model.startDate d

                                        Nothing ->
                                            dateToX model.startDate baselineDate
                                                + ceiling
                                                    (toFloat (baselinePoints - points)
                                                        / toFloat baselinePoints
                                                        * toFloat (targetDateX - dateToX model.startDate baselineDate)
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
            [ ( dateToX model.startDate baselineDate, toFloat <| baselinePoints )
            , ( targetDateX, 0 )
            ]
        , LineChart.line (model.color |> Maybe.withDefault Colors.pink) Dots.circle "Actual" (List.indexedMap (\i x -> ( i, toFloat x )) model.pointsRemaining)
        ]


tupleToDate : Date -> Date.Date
tupleToDate ( year, month, day ) =
    Date.fromCalendarDate year month day


dateToX : Date -> Date -> Int
dateToX startDate_ date_ =
    let
        startDate =
            tupleToDate startDate_

        date =
            tupleToDate date_

        startMonday =
            Date.fromWeekDate
                (Date.year startDate)
                (Date.weekNumber startDate)
                Time.Mon
    in
    Date.diff Date.Days startDate date
        - (2 * Date.diff Date.Weeks startMonday date)


{-| -}
red : Color
red =
    Colors.red


{-| -}
pink : Color
pink =
    Colors.pink


{-| -}
gold : Color
gold =
    Colors.gold


{-| -}
green : Color
green =
    Colors.green


{-| -}
teal : Color
teal =
    Colors.teal


{-| -}
cyan : Color
cyan =
    Colors.cyan


{-| -}
blue : Color
blue =
    Colors.blue


{-| -}
purple : Color
purple =
    Colors.purple
