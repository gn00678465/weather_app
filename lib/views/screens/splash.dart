import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  @override
  void initState() {
    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.of(context).pushReplacementNamed('/current');
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: LottieWidget(),
      ),
    );
  }
}

class LottieWidget extends StatelessWidget {
  const LottieWidget({
    super.key,
    this.frameBuilder,
  });
  final Widget Function(BuildContext, Widget, LottieComposition?)? frameBuilder;

  @override
  Widget build(BuildContext context) {
    _SplashPageState state = context.findAncestorStateOfType()!;
    return Lottie.asset(
      'assets/lottie/splash.json',
      repeat: false,
      fit: BoxFit.fill,
      controller: state._controller,
      width: MediaQuery.of(context).size.width * 0.6,
      onLoaded: (composition) {
        state._controller!
          ..duration = composition.duration
          ..forward();
      },
      frameBuilder: frameBuilder,
    );
  }
}
