module SumNode exposing (..)

import Leaf1
import ProductNode
import Model
import Html exposing (Html)
import UrlParser exposing (Parser, (</>), s, int, string, top, oneOf, parseHash)
import Navigation


type Model
    = Leaf1Model Leaf1.Model
    | ProductNodeModel ProductNode.Model


type Msg
    = Leaf1Msg Leaf1.Msg
    | ProductNodeMsg ProductNode.Msg
    | UrlChange Navigation.Location


type Route
    = Left
    | Right String


route : Parser (Route -> a) a
route =
    oneOf
        [ UrlParser.map Right (s "right" </> string)
        , UrlParser.map Left (s "left")
        , UrlParser.map Left top
        ]


locationChange : Navigation.Location -> ( Model, Cmd Msg )
locationChange location =
    case (parseHash route location) of
        Nothing ->
            Model.map Leaf1Model Leaf1Msg (Leaf1.init)

        Just Left ->
            Model.map Leaf1Model Leaf1Msg (Leaf1.init)

        Just (Right aMessage) ->
            Model.map ProductNodeModel ProductNodeMsg (ProductNode.init aMessage)


init : Navigation.Location -> ( Model, Cmd Msg )
init startLocation =
    locationChange startLocation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( UrlChange location, model ) ->
            locationChange location

        ( Leaf1Msg (Leaf1.Exit aMessage), _ ) ->
            ( model, Navigation.newUrl ("#right/" ++ aMessage) )

        ( ProductNodeMsg (ProductNode.BackMsg _), ProductNodeModel imodel ) ->
            ( model, Navigation.newUrl ("#left") )

        ( Leaf1Msg imsg, Leaf1Model imodel ) ->
            Model.map Leaf1Model Leaf1Msg (Leaf1.update imsg imodel)

        ( ProductNodeMsg imsg, ProductNodeModel imodel ) ->
            Model.map ProductNodeModel ProductNodeMsg (ProductNode.update imsg imodel)

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
