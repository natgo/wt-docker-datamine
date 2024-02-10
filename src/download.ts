import axios from "axios";
import fs from "fs";
import WebTorrent from "webtorrent";

const client = new WebTorrent({ utp: false });

let tag = "";
const outPath = process.argv[2];

switch (outPath) {
  case "dev":
    tag = "&tag=dev";
    break;
  case "rc":
    tag = "&tag=production%2drc";
    break;
}

const yupmaster = await axios.get(
  `https://yupmaster.gaijinent.com/yuitem/current_yup.php?project=warthunder&torrent=1${tag}`,
  { responseType: "arraybuffer" },
);

client.add(yupmaster.data, { path: "./" }, (torrent) => {
  torrent.deselect(0, torrent.pieces.length - 1, 0);

  const fpath = torrent.files[0]?.path.split("/")[0];
  if (!fpath) {
    throw new Error("No fpath");
  }
  const regex = new RegExp(`${fpath}/(ui/)?(?!fonts)(?!slides)[a-z]+.vromfs.bin`, "gi");

  torrent.files.forEach((file) => {
    if (file.path.match(regex)) {
      console.log(file.path);
      file.select();

      // bug
      if (file.name === "game.vromfs.bin" || file.name === "char.vromfs.bin") {
        file.select();
      }
    } else {
      file.deselect();
    }
  });

  torrent.on("done", () => {
    console.log("torrent finished downloading");

    if (!fs.existsSync(`./out/${outPath}`)) {
      fs.mkdirSync(`./out/${outPath}`);
    }

    const folder = fs.readdirSync(`${fpath}/`);
    const uifolder = fs.readdirSync(`${fpath}/ui/`);
    folder.forEach((element) => {
      if (element.endsWith("vromfs.bin")) {
        fs.copyFileSync(`./${fpath}/${element}`, `./out/${outPath}/${element}`);
      }
    });
    uifolder.forEach((element) => {
      if (element.endsWith("vromfs.bin")) {
        fs.copyFileSync(`./${fpath}/ui/${element}`, `./out/${outPath}/${element}`);
      }
    });

    client.destroy(() => {
      console.log("destroyed", outPath);
      fs.rmSync(fpath, { recursive: true });
    });
  });
});
