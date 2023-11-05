import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather_app/constants/text_shadow.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/providers/current_time_provider.dart';

enum WeatherCardPosition {
  top(8),
  left(12),
  right(12),
  bottom(8);

  const WeatherCardPosition(this.value);
  final double value;
}

class WeatherCard extends StatelessWidget {
  final WeatherModel weatherInfo;
  final int index;
  final bool isMinimized;
  final Duration duration = const Duration(milliseconds: 300);
  final String heroTag;
  final void Function()? onTap;

  const WeatherCard({
    super.key,
    required this.index,
    required this.weatherInfo,
    required this.heroTag,
    this.isMinimized = false,
    this.onTap,
  });

  Widget _card() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: duration,
        height: isMinimized ? 56 : 88,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: WeatherModel.weatherImage(weatherInfo),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Stack(
          children: [
            // 顯示地區
            Positioned(
              left: WeatherCardPosition.left.value,
              top: WeatherCardPosition.top.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weatherInfo.currentPosition ? '我的位置' : weatherInfo.city,
                    style: TextStyle(
                      color: CupertinoColors.systemGrey5,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      shadows: outlinedText,
                    ),
                  ),
                  weatherInfo.currentPosition
                      ? Text(
                          weatherInfo.city,
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.white,
                            shadows: outlinedText,
                          ),
                        )
                      : CurrentTime(
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white,
                            shadows: outlinedText,
                          ),
                        ),
                ],
              ),
            ),
            // 顯示溫度
            Positioned(
              right: WeatherCardPosition.right.value,
              top: WeatherCardPosition.top.value,
              child: Text(
                '${weatherInfo.temp}\u00B0',
                style: TextStyle(
                  color: CupertinoColors.lightBackgroundGray,
                  fontSize: 36,
                  shadows: outlinedText,
                ),
              ),
            ),
            // 溫度 range
            Positioned(
              right: WeatherCardPosition.right.value,
              bottom: WeatherCardPosition.bottom.value,
              child: _hideWhenMinimized(
                duration: duration,
                // offstage: isMinimized,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: '最高 ${weatherInfo.temp_max}\u00B0'),
                      const WidgetSpan(child: SizedBox(width: 6)),
                      TextSpan(text: '最低 ${weatherInfo.temp_min}\u00B0'),
                    ],
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            // 狀態
            Positioned(
              left: WeatherCardPosition.left.value,
              bottom: WeatherCardPosition.bottom.value,
              child: _hideWhenMinimized(
                duration: duration,
                // offstage: isMinimized,
                child: Text(
                  weatherInfo.weatherDesc,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: onTap,
        child: _card(),
      ),
    );
  }

  Widget _hideWhenMinimized(
      {required Widget child, required Duration duration}) {
    final Animation<double> parent = CurvedAnimation(
      parent: const AlwaysStoppedAnimation(1),
      curve: Curves.easeInOut,
    );

    return AnimatedSwitcher(
      duration: duration,
      child: !isMinimized
          ? FadeTransition(
              key: const ValueKey(1),
              opacity: Tween<double>(begin: 0, end: 1).animate(parent),
              child: child,
            )
          : FadeTransition(
              key: const ValueKey(2),
              opacity: Tween<double>(begin: 1, end: 0).animate(parent),
              child: child,
            ),
    );
  }
}

class CurrentTime extends ConsumerWidget {
  final TextStyle? style;

  const CurrentTime({super.key, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String> currentTime = ref.watch(currentTimeProvider);

    return currentTime.when(
      skipLoadingOnReload: true,
      data: (data) {
        return Text(
          data,
          style: style,
        );
      },
      error: (err, stack) => Text('Error: $err'),
      loading: () => const SizedBox.shrink(),
    );
  }
}
