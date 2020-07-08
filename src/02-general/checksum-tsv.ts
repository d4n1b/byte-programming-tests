import fs from "fs";
import path from "path";
import csv from "csvtojson";

const readTSV = (filePath: string): Promise<string> => {
  return new Promise((resolve, reject) => {
    fs.readFile(path.join(__dirname, filePath), "utf8", (error, data) => {
      if (error) {
        return reject(error);
      }

      resolve(data);
    });
  });
};

const checksumTSV = async (filePath: string): Promise<number> => {
  let checksum = 0;

  if (typeof filePath !== "string") {
    return checksum;
  }

  try {
    const tsvString = await readTSV(filePath);
    const data = await csv({
      delimiter: "\t",
      noheader: true,
    }).fromString(tsvString);

    for (let rowIndex = 0; rowIndex < data.length; rowIndex++) {
      const column = Object.values(data[rowIndex]);
      let max = Number.NEGATIVE_INFINITY;
      let min = Number.POSITIVE_INFINITY;

      for (let columnIndex = 0; columnIndex < column.length; columnIndex++) {
        const currentNumber = Number(column[columnIndex]);

        if (!Number.isNaN(currentNumber)) {
          max = Math.max(max, currentNumber);
          min = Math.min(min, currentNumber);
        }
      }

      checksum += max - min;
    }
  } catch (error) {
    // ignore
  }

  return checksum;
};

export default checksumTSV;
