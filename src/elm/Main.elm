import Modules.Kve.Main as Kve
import Browser




main = Browser.document {
    init = Kve.init,
    view = Kve.view,
    update = Kve.update,
    subscriptions = Kve.subscriptions
  }


