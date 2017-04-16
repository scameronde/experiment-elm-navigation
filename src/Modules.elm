module Modules exposing (..)

import SumNode
import Html exposing (..)
import Navigation
import Model
import Lens


type alias Model =
    { sumNodeModel : SumNode.Model
    , history : List Navigation.Location
    }


type Msg
    = SumNodeMsg SumNode.Msg
    | UrlChange Navigation.Location


init : Navigation.Location -> ( Model, Cmd Msg )
init startLocation =
    Model.create Model
        |> Model.combine SumNodeMsg SumNode.init
        |> Model.set [ startLocation ]
        |> Model.run


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange newUrl ->
            Model.create Model
                |> Model.combine SumNodeMsg (SumNode.update (SumNode.UrlChange newUrl) model.sumNodeModel)
                |> Model.set (newUrl :: model.history)
                |> Model.run

        SumNodeMsg imsg ->
            Model.map
                (sumNodeLens.fset model)
                SumNodeMsg
                (SumNode.update imsg model.sumNodeModel)


view : Model -> Html Msg
view model =
    Html.map SumNodeMsg (SumNode.view model.sumNodeModel)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map SumNodeMsg (SumNode.subscriptions model.sumNodeModel)


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


sumNodeLens : Lens.Lens { b | sumNodeModel : a } a
sumNodeLens =
    Lens.lens .sumNodeModel (\a b -> { b | sumNodeModel = a })
