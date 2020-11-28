import { keyOfMatchingRange, scale } from 'common/math';
import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps, Box } from './Box';
import { AnimatedNumber } from './AnimatedNumber';

export const RoundGauge = props => {
  if (Byond.IS_LTE_IE8) {
    return (
      <AnimatedNumber {...props} />
    );
  }

  const {
    maxValue,
    minValue,
    unit,
    value,
    format,
    className,
    style,
    fillValue,
    color,
    ranges,
    size = 1,
    bipolar,
    children,
    ...rest
  } = props;

  const scaledValue = scale(
    value,
    minValue,
    maxValue);
  let scaledRanges = ranges ? {} : { "good": [0, 1] };
  if (ranges)
    Object.keys(ranges).forEach(x => {
      const range = ranges[x];
      scaledRanges[x] = [
        scale(range[0], minValue, maxValue),
        scale(range[1], minValue, maxValue),
      ];
    });

  return (
    <Box className="RoundGauge__Container">
      <div
        className={classes([
          'RoundGauge',
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps({
          style: {
            'font-size': size + 'em',
            ...style,
          },
          ...rest,
        })}>
        <svg
          className="RoundGauge__ring RoundGauge__ringTrackPivot"
          viewBox="0 0 100 50">
          <circle
            className="RoundGauge__ringTrack"
            cx="50"
            r="50" />
        </svg>
        {Object.keys(scaledRanges).map((x, i) => {
          const col_ranges = scaledRanges[x];
          return (
            <svg
              className={`RoundGauge__ring RoundGauge--color--${x}`}
              viewBox="0 0 100 50"
              key={i}>
              <circle
                className="RoundGauge__ringFill"
                style={{
                  'stroke-dashoffset': (
                    Math.max((2.0 - (col_ranges[1] - col_ranges[0]))
                      * Math.PI * 50, 0)
                  ),
                }}
                transform={`rotate(${180 + 180 * col_ranges[0]} 50 50)`}
                cx="50"
                cy="50"
                r="50" />
            </svg>
          );
        })}
        <svg
          className="RoundGauge__needle"
          viewBox="0 0 100 50">
          <g transform={`rotate(${scaledValue * 180 - 90} 50 50)`}>
            <polygon
              className="RoundGauge__needleLine"
              points="46,50 50,0 54,50" />
            <circle
              className="RoundGauge__needleMiddle"
              cx="50"
              cy="50"
              r="8" />
          </g>
        </svg>
      </div>
      <AnimatedNumber
        value={value}
        format={format}
        size={size} />
    </Box>
  );
}
