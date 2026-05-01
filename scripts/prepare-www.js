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

console.log("prepare-www: archivos copiados a www/");
