module ProductNode exposing (..)

import Leaf2
import Leaf3
import BackLeaf
import Model
import Html exposing (..)


type alias Model =
    { leaf2Model : Leaf2.Model
    , leaf3Model : Leaf3.Model
    , backModel : BackLeaf.Model
    }


type Msg
    = Leaf2Msg Leaf2.Msg
    | Leaf3Msg Leaf3.Msg
    | BackMsg BackLeaf.Msg


init : String -> ( Model, Cmd Msg )
init aMessage =
    Model.create Model
        |> Model.combine Leaf2Msg (Leaf2.init aMessage)
        |> Model.combine Leaf3Msg (Leaf3.init aMessage)
        |> Model.combine BackMsg BackLeaf.init
        |> Model.run


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Leaf2Msg imsg ->
            updateLeaf2 imsg model

        Leaf3Msg imsg ->
            updateLeaf3 imsg model

        _ ->
            ( model, Cmd.none )


updateLeaf2 : Leaf2.Msg -> Model -> ( Model, Cmd Msg )
updateLeaf2 msg model =
    case msg of
        Leaf2.Send aMessage ->
            Leaf3.update (Leaf3.Receive aMessage) model.leaf3Model
                |> Model.map (\a -> { model | leaf3Model = a }) Leaf3Msg

        _ ->
            Leaf2.update msg model.leaf2Model
                |> Model.map (\a -> { model | leaf2Model = a }) Leaf2Msg


updateLeaf3 : Leaf3.Msg -> Model -> ( Model, Cmd Msg )
updateLeaf3 msg model =
    case msg of
        Leaf3.Send aMessage ->
            Leaf2.update (Leaf2.Receive aMessage) model.leaf2Model
                |> Model.map (\a -> { model | leaf2Model = a }) Leaf2Msg

        _ ->
            Leaf3.update msg model.leaf3Model
                |> Model.map (\a -> { model | leaf3Model = a }) Leaf3Msg


view : Model -> Html Msg
view model =
    div []
        [ Html.map Leaf2Msg (Leaf2.view model.leaf2Model)
        , Html.map Leaf3Msg (Leaf3.view model.leaf3Model)
        , Html.map BackMsg (BackLeaf.view model.backModel)
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map Leaf2Msg (Leaf2.subscriptions model.leaf2Model)
        , Sub.map Leaf3Msg (Leaf3.subscriptions model.leaf3Model)
        , Sub.map BackMsg (BackLeaf.subscriptions model.backModel)
        ]
