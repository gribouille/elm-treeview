module Example1 exposing (main)

import Html
import Treeview as T
import Data exposing (styles, model)


config : T.Config
config = T.default styles


main : Program Never T.Model T.Msg 
main =
  Html.beginnerProgram
    { model = model
    , view = T.view config
    , update = T.update 
    }
