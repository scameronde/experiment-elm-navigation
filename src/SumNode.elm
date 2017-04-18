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


{-| Routes should be typesafe.
-}
type Route
    = Left
    | Right String


{-| Define the possible routes of this sum node.
-}
route : Parser (Route -> a) a
route =
    oneOf
        [ UrlParser.map Right (s "right" </> string)
        , UrlParser.map Left (s "left")
        , UrlParser.map Left top
        ]


{-| React to location change by initializing the correct leaf of this node.
-}
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
        -- react to url change with location change
        ( UrlChange location, model ) ->
            locationChange location

        -- switch to ProductNode as result of a message from Leaf1
        ( Leaf1Msg (Leaf1.Exit aMessage), _ ) ->
            ( model, Navigation.newUrl ("#right/" ++ aMessage) )

        -- switch to Leaf1 as result of a message from ProductNode
        ( ProductNodeMsg (ProductNode.BackMsg _), ProductNodeModel imodel ) ->
            ( model, Navigation.newUrl ("#left") )

        -- let Leaf1 handle it's other messages
        ( Leaf1Msg imsg, Leaf1Model imodel ) ->
            Model.map Leaf1Model Leaf1Msg (Leaf1.update imsg imodel)

        -- let ProductNode handle it's own messages
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
