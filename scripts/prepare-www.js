/**
 * Copia solo archivos estáticos del front al directorio www/ para Capacitor sync.
 * Ignora node_modules, scripts SQL, README, etc.
 */
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const www = path.join(root, "www");

const ALLOW = /\.(html|png|jpg|jpeg|gif|webp|svg|ico|json|woff2?|txt)$/i;
const DENY_NAMES = new Set(["package.json", "package-lock.json"]);

if (!fs.existsSync(www)) fs.mkdirSync(www, { recursive: true });

for (const name of fs.readdirSync(root)) {
  const full = path.join(root, name);
  if (!fs.statSync(full).isFile()) continue;
  if (DENY_NAMES.has(name)) continue;
  if (!ALLOW.test(name)) continue;
  fs.copyFileSync(full, path.join(www, name));
}

function copyTree(srcDir, destDir) {
  if (!fs.existsSync(srcDir)) return;
  fs.mkdirSync(destDir, { recursive: true });
  for (const ent of fs.readdirSync(srcDir, { withFileTypes: true })) {
    const src = path.join(srcDir, ent.name);
    const dest = path.join(destDir, ent.name);
    if (ent.isDirectory()) {
      copyTree(src, dest);
    } else if (ALLOW.test(ent.name)) {
      fs.copyFileSync(src, dest);
    }
  }
}

copyTree(path.join(root, "assets"), path.join(www, "assets"));

const legacyLogo = path.join(root, "almacenhoney.png");
const legacyLogoDest = path.join(www, "assets", "almacenhoney.png");
if (fs.existsSync(legacyLogo)) {
  fs.mkdirSync(path.dirname(legacyLogoDest), { recursive: true });
  fs.copyFileSync(legacyLogo, legacyLogoDest);
}

console.log("prepare-www: archivos copiados a www/");
