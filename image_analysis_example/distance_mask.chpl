module distance_mask {

proc create_distance_mask(radius : int) {

  const D : domain(2, int) = {-radius..radius, -radius..radius};

  var dist : [D] real;

  var Mask : [D] bool;

  for (i,j) in dist.domain do {
    dist[i,j] = sqrt(i**2 + j**2);
  }

  // Using < here instead of <= because <= leaves only one point at the edge of the
  // domain, and it becomes difficult to define the left and right masks in a sensible way.
  Mask = (dist < radius);

  return Mask;
}

} // distance_mask

