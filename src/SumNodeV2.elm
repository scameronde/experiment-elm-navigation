module SumNodeV2 exposing (..)

import Leaf1
import ProductNodeV2 as ProductNode
import Model
import Html exposing (..)
import Navigation


type Model
    = Leaf1Model Leaf1.Model
    | ProductNodeModel ProductNode.Model


type Msg
    = Leaf1Msg Leaf1.Msg
    | ProductNodeMsg ProductNode.Msg


init : ( Model, Cmd Msg )
init =
    Model.create Leaf1Model
        |> Model.combine Leaf1Msg Leaf1.init
        |> Model.run
        |> Model.andThenDo (Navigation.newUrl "sum")


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Leaf1Msg (Leaf1.Exit aMessage), _ ) ->
            ProductNode.init aMessage
                |> Model.map ProductNodeModel ProductNodeMsg

        ( Leaf1Msg imsg, Leaf1Model imodel ) ->
            Leaf1.update imsg imodel
                |> Model.map Leaf1Model Leaf1Msg

        ( ProductNodeMsg (ProductNode.BackMsg _), ProductNodeModel imodel ) ->
            Leaf1.init
                |> Model.map Leaf1Model Leaf1Msg

        ( ProductNodeMsg imsg, ProductNodeModel imodel ) ->
            ProductNode.update imsg imodel
                |> Model.map ProductNodeModel ProductNodeMsg

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        Leaf1Model imodel ->
            Html.map Leaf1Msg (Leaf1.view imodel)

        ProductNodeModel imodel ->
            Html.map ProductNodeMsg (ProductNode.view imodel)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Leaf1Model imodel ->
            Sub.map Leaf1Msg (Leaf1.subscriptions imodel)

        ProductNodeModel imodel ->
            Sub.map ProductNodeMsg (ProductNode.subscriptions imodel)
