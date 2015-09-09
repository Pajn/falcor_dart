library falcor_dart.normalize;

/**
 * takes in a range and normalizes it to have a to / from
 */
normalize(range) {
  var from = range.from || 0;
  var to;
  if (typeof range.to === 'number') {
    to = range.to;
  } else {
    to = from + range.length - 1;
  }

  return {to: to, from: from};
}
