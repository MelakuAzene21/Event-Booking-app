const fs = require("fs");
const path = require("path");

// Function to load and replace template placeholders
const loadTemplate = (templateName, replacements) => {
    const filePath = path.join(__dirname, `../templates/${templateName}.html`);
    let template = fs.readFileSync(filePath, "utf-8");

    // Replace placeholders like {{name}}, {{eventTitle}}, etc.
    Object.keys(replacements).forEach(key => {
        template = template.replace(new RegExp(`{{${key}}}`, "g"), replacements[key]);
    });

    return template;
};

module.exports = loadTemplate;
