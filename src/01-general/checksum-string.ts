// DEVELOPER NOTES:
// The exercise doens't specify, but I assumed that data is a valud type string.
// If the client needs to parse a numnber that big, it might need to use a node Buffer/raw data.

const checksumString = (data: string): number => {
  if (typeof data !== "string") {
    return 0;
  }

  const length = data.length - 1;
  const first = Number(data[0]);

  let checksum = 0;

  for (let i = 0; i <= length; i++) {
    const current = Number(data[i]);
    const prev = Number(data[i + 1]);

    if (current === prev) {
      checksum += current;
    }
    // Check circular: last & end
    if (i === length && first === current) {
      checksum += current;
    }
  }

  return checksum;
};

export default checksumString;
