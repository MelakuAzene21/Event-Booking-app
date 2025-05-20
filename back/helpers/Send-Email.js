const dotenv = require('dotenv');
dotenv.config();
// // Configure SMTP transporter
// const transporter = nodemailer.createTransport({
//     service: "gmail",
//     auth: {
//         user: process.env.NODEMAILER_EMAIL, // Your email
//         pass: process.env.NODEMAILER_PASSWORD  // Your email app password
//     }
// });

// // Function to send email
// const sendEmail = async (to, subject, htmlContent) => {
//     try {
//         await transporter.sendMail({
//             from: process.env.NODEMAILER_EMAIL,
//             to,
//             subject,
//             html: htmlContent
//         });
//         console.log("Email sent successfully!");
//     } catch (error) {
//         console.error("Error sending email:", error);
//     }
// };

// module.exports = sendEmail;





const nodemailer = require("nodemailer");
const loadTemplate = require("./emailTemplates");

// Configure email sender
const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: process.env.NODEMAILER_EMAIL,
        pass: process.env.NODEMAILER_PASSWORD
    }
});

// Function to send email using templates
const sendEmail = async (to, subject, templateName, replacements, attachments = []) => {
    try {
        const htmlContent = loadTemplate(templateName, replacements);

        await transporter.sendMail({
            from: process.env.NODEMAILER_EMAIL,
            to,
            subject,
            html: htmlContent,
            attachments: attachments // Attach QR codes

        });

        console.log("Email sent successfully!");
    } catch (error) {
        console.error("Error sending email:", error);
    }
};

module.exports = sendEmail;

