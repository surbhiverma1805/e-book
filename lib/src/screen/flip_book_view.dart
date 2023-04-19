/*
class FlipBookView extends StatelessWidget {
  final flipBookToolbarItemsConfigEN =
      FlipBookToolbarItemsConfig(locale: FlipBookLocales.en);
  final flipBookToolbarItemsConfigHE = FlipBookToolbarItemsConfig(
      locale: FlipBookLocales.he, direction: TextDirection.rtl);

  FlipBookView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlipBookControllers buildFlipBookControllers =
        Provider.of<FlipBookControllers>(context);
    return Scaffold(
      body: Row(
        children: [
          Visibility(
            visible:
                !buildFlipBookControllers.flipBookControllerHE.isFullScreen,
            child: Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlipBookToolbarItemFullscreen(
                                buildFlipBookControllers.flipBookControllerEN,
                                flipBookToolbarItemsConfigEN)
                            .child,
                        */
/*  FlipBookToolbarItemCover(
                            buildFlipBookControllers.flipBookControllerEN,
                            flipBookToolbarItemsConfigEN)
                            .child,*//*

                        */
/*   FlipBookToolbarItemPrev(
                            buildFlipBookControllers.flipBookControllerEN,
                            flipBookToolbarItemsConfigEN)
                            .child,
                        FlipBookToolbarItemNext(
                            buildFlipBookControllers.flipBookControllerEN,
                            flipBookToolbarItemsConfigEN)
                            .child,
                        FlipBookToolbarItemTOC(
                            buildFlipBookControllers.flipBookControllerEN,
                            flipBookToolbarItemsConfigEN,
                            5)
                            .child,*//*

                      ],
                    ),
                  ),
                  Expanded(
                    child: FlipBook.builder(
                        controller:
                            buildFlipBookControllers.flipBookControllerEN,
                        pageBuilder: enPageBuilder),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: !buildFlipBookControllers
                    .flipBookControllerEN.isFullScreen ||
                (buildFlipBookControllers.flipBookControllerHE.isFullScreen &&
                    buildFlipBookControllers.flipBookControllerEN.isFullScreen),
            child: Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      automaticallyImplyLeading: false,
                      centerTitle: true,
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FlipBookToolbarItemFullscreen(
                                  buildFlipBookControllers.flipBookControllerHE,
                                  flipBookToolbarItemsConfigHE)
                              .child,
                          FlipBookToolbarItemCover(
                                  buildFlipBookControllers.flipBookControllerHE,
                                  flipBookToolbarItemsConfigHE)
                              .child,
                          FlipBookToolbarItemPrev(
                                  buildFlipBookControllers.flipBookControllerHE,
                                  flipBookToolbarItemsConfigHE)
                              .child,
                          FlipBookToolbarItemNext(
                                  buildFlipBookControllers.flipBookControllerHE,
                                  flipBookToolbarItemsConfigHE)
                              .child,
                          FlipBookToolbarItemTOC(
                                  buildFlipBookControllers.flipBookControllerHE,
                                  flipBookToolbarItemsConfigHE,
                                  5)
                              .child,
                        ],
                      ),
                    ),
                    Expanded(
                        child: FlipBook.builder(
                            controller:
                                buildFlipBookControllers.flipBookControllerHE,
                            direction: TextDirection.rtl,
                            pageSemantics: hePageSemantics,
                            pageBuilder: hePageBuilder))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
*/
