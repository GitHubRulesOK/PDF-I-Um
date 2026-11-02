# PDF-I-Um Viewer

A lightweight, self-building PDF viewer for Windows simply download the CMD and run.
No binary installer. No tabs. No fuss.

PDF-I-Um is a compact Windows PDF viewer built in native Windows C# using latest PDFium.dll for the hard work.

Designed to run even on older Windows systems as well as modern Windows, thus including Windows 7 32-bit.

![mage](https://github.com/GitHubRulesOK/PDF-I-Um/blob/main/PDF-I-Um.png?raw=true)

## Getting started
Download just the cmd file or clone this repository as a zip file and run:

PDF-I-Um.cmd

The CMD file downloads the required PDFium runtime if necessary and compiles the application locally using the installed .NET Framework C# compiler.

No precompiled executable or NuGet installation is required.

# Opening documents
Double-click the application, use Open, or simply drag a PDF onto its window.

You can also launch it with a filename:

PDF-I-Um.exe "My Document.pdf"

Dropping another PDF onto the existing window replaces the current document. No tabs, no multiple-document clutter.

# Compatibility
Windows 7 SP1 (32-bit)  
Windows 10  
Windows 11  
Requires the .NET Framework compiler and the appropriate PDFium x86 runtime.  

# Technical notes
C# / Windows Forms  
PDFium native rendering engine  
Compiled locally with Microsoft's C# compiler  

Target architecture: x86  
PDFium runtime: 158.0.8125  
PDF-I-Um — just open the PDF.  
