import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const inputPath = "C:/Users/Gokic/Desktop/JaviCalorias/Copia de Volumen.xlsx";
const input = await FileBlob.load(inputPath);
const workbook = await SpreadsheetFile.importXlsx(input);

const summary = await workbook.inspect({
  kind: "workbook,sheet,table,definedName,drawing",
  maxChars: 12000,
  tableMaxRows: 12,
  tableMaxCols: 18,
  tableMaxCellChars: 120,
});
console.log("SUMMARY\n" + summary.ndjson);

const sheets = workbook.worksheets.items;
for (const sheet of sheets) {
  console.log(`\nSHEET ${sheet.name}`);
  const used = sheet.getUsedRange();
  if (!used) continue;
  console.log("USED", used.address ?? "unknown");
  const region = await workbook.inspect({
    kind: "region",
    sheetId: sheet.name,
    range: used.address ?? "A1:Z100",
    maxChars: 12000,
  });
  console.log(region.ndjson);
  const formulas = await workbook.inspect({
    kind: "formula",
    sheetId: sheet.name,
    range: used.address ?? "A1:Z100",
    options: { maxResults: 300 },
    maxChars: 12000,
  });
  console.log("FORMULAS\n" + formulas.ndjson);
  const preview = await workbook.render({ sheetName: sheet.name, autoCrop: "all", scale: 1, format: "png" });
  await fs.writeFile(`workbook_${sheet.name.replace(/[^a-z0-9_-]/gi, "_")}.png`, new Uint8Array(await preview.arrayBuffer()));
}
