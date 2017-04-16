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
    = UrlChange Navigation.Location
    | Leaf1Msg Leaf1.Msg
    | ProductNodeMsg ProductNode.Msg


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


init : ( Model, Cmd Msg )
init =
    Model.create Leaf1Model
        |> Model.combine Leaf1Msg Leaf1.init
        |> Model.run


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( UrlChange location, model ) ->
            case (parseHash route location) of
                Nothing ->
                    case model of
                        Leaf1Model imodel ->
                            ( model, Cmd.none )

                        ProductNodeModel imodel ->
                            Model.map Leaf1Model Leaf1Msg (Leaf1.init)

                Just Left ->
                    case model of
                        Leaf1Model imodel ->
                            ( model, Cmd.none )

                        ProductNodeModel imodel ->
                            Model.map Leaf1Model Leaf1Msg (Leaf1.init)

                Just (Right aMessage) ->
                    case model of
                        Leaf1Model imodel ->
                            Model.map ProductNodeModel ProductNodeMsg (ProductNode.init aMessage)

                        ProductNodeModel imodel ->
                            Model.map ProductNodeModel ProductNodeMsg (ProductNode.init aMessage)

        ( Leaf1Msg (Leaf1.Exit aMessage), _ ) ->
            ( model, Navigation.newUrl ("#right/" ++ aMessage) )

        ( Leaf1Msg imsg, Leaf1Model imodel ) ->
            Leaf1.update imsg imodel
                |> Model.map Leaf1Model Leaf1Msg

        ( ProductNodeMsg (ProductNode.BackMsg _), ProductNodeModel imodel ) ->
            ( model, Navigation.newUrl ("#left") )

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
