const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");
const fs = require("fs");
const path = require("path");
const AdmZip = require("adm-zip");
const { exec } = require("child_process");
require("dotenv").config({ path: "./.env" });

const s3 = new S3Client({
  region: process.env.REGION,
  credentials: {
    accessKeyId: process.env.ACCESS_KEY, // Replace with your access key
    secretAccessKey: process.env.SECRET_ACCESS_KEY, // Replace with your secret key
  },
});

// Function to ensure the folder exists
const ensureFolderExists = (folderPath) => {
  if (!fs.existsSync(folderPath)) {
    fs.mkdirSync(folderPath, { recursive: true }); // Creates the folder if it doesn't exist
  }
};

// Download and unzip the file
const downloadAndUnzip = async (folderPath, fileName) => {
  // Ensure the folder exists
  ensureFolderExists(folderPath);

  const filePath = path.join(folderPath, fileName);
  const params = {
    Bucket: "bucketuni",
    Key: "hashith/UFill_V2.zip", // Replace with your ZIP file's key
  };

  try {
    const data = await s3.send(new GetObjectCommand(params));
    const fileStream = fs.createWriteStream(filePath);

    // Download the file
    data.Body.pipe(fileStream);

    fileStream.on("close", () => {
      console.log("ZIP file downloaded successfully to:", filePath);

      // Unzip the file after downloading
      unzipFile(filePath, folderPath);
      startServer();
      pm2StartService();
      pm2StartServer();
    });
  } catch (err) {
    console.error(`Error downloading file: ${err.message}`);
  }
};

// Function to unzip the downloaded file
const unzipFile = (zipFilePath, outputFolder) => {
  const zip = new AdmZip(zipFilePath);

  if (!checkExistance("/UFill_V2")) {
    zip.extractAllTo(outputFolder, true); // true allows overwriting existing files
  } else {
    removeFolder();
    zip.extractAllTo(outputFolder, true); // true allows overwriting existing files
  }
  console.log("Files unzipped successfully to:", outputFolder);
};

const startServer = () => {
  exec("cd UFill_V2 && npm i", (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing command: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`Standard Error: ${stderr}`);
      return;
    }
    console.log(`Standard Output: ${stdout}`);
  });
};

const pm2StartService = () => {
  exec(
    "sudo pm2 start --name 'UFill_v2' npm -- start && sudo pm2 startup && sudo pm2 save",
    (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing command: ${error.message}`);
        return;
      }
      if (stderr) {
        console.error(`Standard Error: ${stderr}`);
        return;
      }
      console.log(`Standard Output: ${stdout}`);
    }
  );
};

const pm2StartServer = () => {
  exec("pm2 start --name 'UFill' npm -- start", (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing command: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`Standard Error: ${stderr}`);
      return;
    }
    console.log(`Standard Output: ${stdout}`);
  });
};

const removeFolder = () => {
  exec("sudo rm -rf UFill_V2", (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing command: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`Standard Error: ${stderr}`);
      return;
    }
    console.log(`Standard Output: ${stdout}`);
  });
};

const checkExistance = (fileName) => {
  if (fs.existsSync(`./${fileName}`)) {
    return true;
  } else {
    return false;
  }
};

// Call the download function and specify the folder path and file name
const folderPath = "/Users/hashithsithuruwan/Desktop/temp11";
const zipFileName = "yourfile.zip";

downloadAndUnzip(folderPath, zipFileName);
