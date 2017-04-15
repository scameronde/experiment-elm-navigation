module BackLeaf exposing (..)

import Html exposing (..)
import Html.Events exposing (..)


type alias Model =
    {}


type Msg
    = Back


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [] [ button [ onClick Back ] [ text "Back" ] ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
