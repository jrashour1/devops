import { writeFile } from "fs";
const data = `{
    "url":"${process.env.URL}"
}`

writeFile('./config.json',data,()=>{})