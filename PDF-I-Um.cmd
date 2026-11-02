/*&cls&@echo off&rem	SEE THE NOTES BELOW this file is open text sourced so you can see it does NOT work outside of your device
REM			Any hint that this file or its .exe are viral, are poor FALSE positives due to method of how it is built.
cd /d "%~dp0" & setlocal enabledelayedexpansion

rem We need to download and unpack the dependency first so that is curl down and untar or download and manually unpack,
rem however to allow for windows 7x32 users we need a complex way to automate that which is almost as long as the program !
set "DLL=%~dp0pdfium.dll"
set "PKG=%~dp0pdfium.nupkg"
set "URL=https://globalcdn.nuget.org/packages/bblanchon.pdfium.win32.158.0.8125.nupkg"
if exist "%DLL%" (echo PDFium DLL already present.&echo Nothing to download.&goto :MAIN)
echo PDFium DLL not found.&echo.
if exist "%PKG%" (echo Cached NuGet package found.&goto :extract)
echo NuGet package not found.&echo.
echo Attempting PowerShell TLS 1.2 download...&echo This may take 30 seconds or more on slow connections.&echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop';" ^
 "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;" ^
 "$w=New-Object Net.WebClient;" "$w.DownloadFile('%URL%','%PKG%.tmp');" ^
 "if((Get-Item '%PKG%.tmp').Length -lt 1000000){throw 'Package too small or invalid'};" ^
 "Move-Item '%PKG%.tmp' '%PKG%' -Force;"
if errorlevel 1 goto :downloadfail
if not exist "%PKG%" goto :downloadfail
echo.&echo Download successful.&echo.

:extract
echo.&echo Preparing NuGet package for extraction...
if exist "%~dp0pdfium.zip" del "%~dp0pdfium.zip"
ren "%PKG%" pdfium.zip
if errorlevel 1 goto :extractfail
set "PKG=%~dp0pdfium.zip"
set "UNPACK=%TEMP%\pdfium_unpack"
if exist "%UNPACK%" rd /s /q "%UNPACK%"
md "%UNPACK%"
echo Extracting PDFium x86 DLL...&echo.
echo Set sh = CreateObject("Shell.Application") >"%~dp0unzip.vbs"
echo Set z = sh.NameSpace("%PKG%") >>"%~dp0unzip.vbs"
echo Set d = sh.NameSpace("%UNPACK%") >>"%~dp0unzip.vbs"
echo If z Is Nothing Or d Is Nothing Then WScript.Quit 1 >>"%~dp0unzip.vbs"
echo d.CopyHere z.Items, 16 >>"%~dp0unzip.vbs"
cscript //nologo "%~dp0unzip.vbs"
if errorlevel 1 goto :extractfail
:waitdll
if exist "%UNPACK%\runtimes\win-x86\native\pdfium.dll" goto :copydll
ping 127.0.0.1 -n 2 >nul
goto :waitdll
:copydll
copy /y "%UNPACK%\runtimes\win-x86\native\pdfium.dll" "%DLL%" >nul
if errorlevel 1 goto :extractfail
echo.&echo PDFium extraction successful!&echo.
del "%~dp0unzip.vbs" 2>nul
rd /s /q "%UNPACK%" 2>nul
goto :MAIN

REM ---- Error handling ----
:downloadfail
echo.&echo WARNING: Automatic download failed.&echo.&echo Check TLS 1.2 and internet connectivity.
echo You can download the package on another PC&echo and copy pdfium.nupkg into this directory.
echo.&del "%PKG%.tmp" 2>nul
goto :MAIN

:extractfail
echo. &echo WARNING: Automatic extraction failed.&echo. &echo The NuGet package has been retained:
echo %PKG%&echo.&echo MANUAL FALLBACK:&echo. &echo 1. Open pdfium.zip using Windows Explorer.
echo 2. Navigate to:&echo    runtimes\win-x86\native\ &echo 3. Copy pdfium.dll into:&echo    %~dp0
echo. &echo No further download is necessary. &echo.

:MAIN
set "CSC=%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" set "CSC=%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if not exist "%CSC%" ( echo Compiler not found & pause & exit /b )
for %%I in ("%CSC%") do set "CSCDIR=%%~dpI"
set "PATH=%CSCDIR%;%PATH%"

"%CSC%" /nologo /optimize /t:winexe /platform:x86 /r:System.IO.Compression.dll /r:System.IO.Compression.FileSystem.dll /out:"%~n0.exe" "%~0"
if errorlevel 1 ( echo Compilation failed & pause & exit /b 1 )

if not exist "%~dpn0.exe" echo "%~dpn0" not found, possibly compile failed.
if exist "%~dpn0.exe" echo Windows native CS Compilation as "%~n0.exe"succeeded
pause
exit /b

NOTES
-----
Recomended name "PDF-I-Um"........Version 1 release 2026-11-02-1

This is a self‑compiling C# utility.
Run this .CMD file to compile PDF-I-Um.exe.

The purpose is to build PDF-I-Um.exe but first download the PDfium.dll resource it needs.

The core c# based code follows this file comments marker
*/using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Printing;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;

using System.Reflection;
[assembly: AssemblyDescription("Self-building PDFViewer")]
[assembly: AssemblyTitle("PDF-I-Um")]
[assembly: AssemblyProduct("PDF-I-Um")]
[assembly: AssemblyCompany("GHROK 2026.11.02")]
[assembly: AssemblyCopyright("GHROK 2026.11.02")]
[assembly: AssemblyVersion("1.2026.11.02")]
[assembly: AssemblyFileVersion("1.2026.11.02")]

static class PDF
{
    const string D = "pdfium.dll";
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern void FPDF_InitLibrary();
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern IntPtr FPDF_LoadDocument(byte[] path, IntPtr password);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern void FPDF_CloseDocument(IntPtr doc);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern int FPDF_GetPageCount(IntPtr doc);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern IntPtr FPDF_LoadPage(IntPtr doc, int index);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern void FPDF_ClosePage(IntPtr page);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern double FPDF_GetPageWidth(IntPtr page);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern double FPDF_GetPageHeight(IntPtr page);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern IntPtr FPDFBitmap_Create(int w, int h, int alpha);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern void FPDFBitmap_Destroy(IntPtr bitmap);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern void FPDFBitmap_FillRect(IntPtr bitmap, int x, int y, int w, int h, uint color);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern IntPtr FPDFBitmap_GetBuffer(IntPtr bitmap);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern int FPDFBitmap_GetStride(IntPtr bitmap);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern void FPDF_RenderPageBitmap(IntPtr bitmap, IntPtr page, int x, int y, int w, int h, int rotate, int flags);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern uint FPDF_GetLastError();
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern IntPtr FPDFText_LoadPage(IntPtr page);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern void FPDFText_ClosePage(IntPtr text);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern int FPDFText_CountChars(IntPtr text);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern int FPDFText_GetCharIndexAtPos(IntPtr text, double x, double y, double xTolerance, double yTolerance);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern int FPDFText_GetText(IntPtr text, int start, int count, ushort[] buffer);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern int FPDFText_GetCharBox(IntPtr text, int index, out double left, out double right, out double bottom, out double top);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern IntPtr FPDFText_FindStart(IntPtr text, byte[] search, uint flags, int startIndex);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern int FPDFText_FindNext(IntPtr search);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern int FPDFText_GetSchResultIndex(IntPtr search);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern int FPDFText_GetSchCount(IntPtr search);
    [DllImport(D, CallingConvention=CallingConvention.StdCall)] public static extern void FPDFText_FindClose(IntPtr search);
}

class Program
{
    [STAThread]
    static void Main()
    {
        try
        {
            PDF.FPDF_InitLibrary();
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Viewer());
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.ToString(), "PDF-I-Um");
        }
    }
}

class Viewer : Form
{
    IntPtr doc = IntPtr.Zero;
    int pageCount;
    int pageNo;
    int rotation;
    int selectionStart = -1;
    int selectionEnd = -1;
    int highlightStart = -1;
    int highlightCount;
    double zoom = 1.5;
    double pageWidth;
    double pageHeight;
    bool fitMode;
    bool fitWidth;
    bool selecting;
    PictureBox picture;
    Panel scroll;
    FlowLayoutPanel thumbs;
    Label status;
    ToolStrip toolbar;
    SplitContainer split;
    PrintDocument printer;
    int printPage;
    // Bounded Find Next state.
    string searchTerm = "";
    byte[] searchBytes;
    int searchStartPage = -1;
    int searchCursorPage = -1;
    int searchCursorChar;
    bool searchActive;

    public Viewer()
    {
        Text = "PdfIUmLite";
        Width = 1100;
        Height = 800;
        MinimumSize = new Size(600, 400);
        StartPosition = FormStartPosition.CenterScreen;
        AllowDrop = true;
        DragEnter += OnDragEnter;
        DragDrop += OnDragDrop;
        toolbar = new ToolStrip();
        toolbar.Dock = DockStyle.Top;
        AddButton("Open", Open);
        AddButton("−", delegate { SetZoom(zoom / 1.2); });
        AddButton("+", delegate { SetZoom(zoom * 1.2); });
        AddButton("Fit page", delegate
        {
            fitMode = true;
            fitWidth = false;
            ShowPage(pageNo);
        });
        AddButton("Fit width", delegate
        {
            fitMode = true;
            fitWidth = true;
            ShowPage(pageNo);
        });
        AddButton("Rotate", Rotate);
        AddButton("Find", Search);
        AddButton("Find Next", FindNext);
        AddButton("Print", Print);
        split = new SplitContainer();
        split.Orientation = Orientation.Vertical;
        split.FixedPanel = FixedPanel.Panel1;
        split.SplitterWidth = 5;
        split.Size = new Size(1000, 700);
        split.SplitterDistance = 150;
        split.Panel1MinSize = 90;
        split.Panel2MinSize = 250;
        split.Dock = DockStyle.Fill;
        thumbs = new FlowLayoutPanel();
        thumbs.Dock = DockStyle.Fill;
        thumbs.AutoScroll = true;
        thumbs.FlowDirection = FlowDirection.TopDown;
        thumbs.WrapContents = false;
        thumbs.BackColor = Color.LightGray;
        split.Panel1.Controls.Add(thumbs);
        scroll = new Panel();
        scroll.Dock = DockStyle.Fill;
        scroll.AutoScroll = true;
        scroll.BackColor = Color.DimGray;
        picture = new PictureBox();
        picture.SizeMode = PictureBoxSizeMode.Normal;
        picture.BackColor = Color.White;
        picture.Location = new Point(10, 10);
        picture.Paint += PaintHighlights;
        picture.MouseDown += SelectStart;
        picture.MouseMove += SelectMove;
        picture.MouseUp += SelectEnd;
        picture.MouseWheel += Wheel;
        scroll.Controls.Add(picture);
        split.Panel2.Controls.Add(scroll);
        status = new Label();
        status.Dock = DockStyle.Bottom;
        status.Height = 25;
        status.Text = "Ready";
        Controls.Add(split);
        Controls.Add(status);
        Controls.Add(toolbar);
        FormClosing += delegate { CloseDocument(); };
    }

    void AddButton(string name, EventHandler handler)
    {
        ToolStripButton b = new ToolStripButton(name);
        b.DisplayStyle = ToolStripItemDisplayStyle.Text;
        b.Click += handler;
        toolbar.Items.Add(b);
    }

    void OnDragEnter(object sender, DragEventArgs e)
    {
        if (e.Data.GetDataPresent(DataFormats.FileDrop))
            e.Effect = DragDropEffects.Copy;
    }

    void OnDragDrop(object sender, DragEventArgs e)
    {
        string[] files =
            (string[])e.Data.GetData(DataFormats.FileDrop);
        if (files.Length > 0 &&
            System.IO.Path.GetExtension(files[0]).ToLower() == ".pdf")
            LoadPdf(files[0]);
    }

    void Open(object sender, EventArgs e)
    {
        using (OpenFileDialog d = new OpenFileDialog())
        {
            d.Filter = "PDF files (*.pdf)|*.pdf";
            if (d.ShowDialog() == DialogResult.OK)
                LoadPdf(d.FileName);
        }
    }

    void LoadPdf(string filename)
    {
        try
        {
            CloseDocument();
            doc = PDF.FPDF_LoadDocument(
                Encoding.UTF8.GetBytes(filename + "\0"),
                IntPtr.Zero);
            if (doc == IntPtr.Zero)
                throw new Exception(
                    "PDFium error: " + PDF.FPDF_GetLastError());
            pageCount = PDF.FPDF_GetPageCount(doc);
            if (pageCount <= 0)
                throw new Exception("PDF contains no pages.");
            pageNo = 0;
            rotation = 0;
            zoom = 1.5;
            fitMode = false;
            ResetSearch();
            BuildThumbnails();
            ShowPage(0);
            Text = "Pdf-I-Um-Lite - " + filename;
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.ToString(), "Open PDF");
            CloseDocument();
        }
    }

    Bitmap Render(IntPtr page, double scale, int rotate)
    {
        double w = PDF.FPDF_GetPageWidth(page);
        double h = PDF.FPDF_GetPageHeight(page);
        if (rotate == 1 || rotate == 3)
        {
            double t = w;
            w = h;
            h = t;
        }
        int width = Math.Max(1, (int)Math.Ceiling(w * scale));
        int height = Math.Max(1, (int)Math.Ceiling(h * scale));
        if (width > 12000 || height > 12000)
            throw new Exception("Page render is too large.");
        IntPtr bmp = PDF.FPDFBitmap_Create(width, height, 0);
        if (bmp == IntPtr.Zero)
            throw new Exception("Cannot create PDFium bitmap.");
        try
        {
            PDF.FPDFBitmap_FillRect(
                bmp, 0, 0, width, height, 0xFFFFFFFF);
            PDF.FPDF_RenderPageBitmap(
                bmp, page, 0, 0, width, height, rotate, 1);
            IntPtr buffer = PDF.FPDFBitmap_GetBuffer(bmp);
            int stride = PDF.FPDFBitmap_GetStride(bmp);
            if (buffer == IntPtr.Zero || stride < width * 4)
                throw new Exception("Invalid PDFium bitmap buffer.");
            Bitmap result = new Bitmap(
                width, height, PixelFormat.Format32bppRgb);
            BitmapData data = result.LockBits(
                new Rectangle(0, 0, width, height),
                ImageLockMode.WriteOnly,
                PixelFormat.Format32bppRgb);
            try
            {
                byte[] row = new byte[width * 4];
                for (int y = 0; y < height; y++)
                {
                    Marshal.Copy(
                        new IntPtr(buffer.ToInt64() + (long)y * stride),
                        row, 0, row.Length);
                    Marshal.Copy(
                        row, 0,
                        new IntPtr(data.Scan0.ToInt64() +
                            (long)y * data.Stride),
                        row.Length);
                }
            }
            finally
            {
                result.UnlockBits(data);
            }
            return result;
        }
        finally
        {
            PDF.FPDFBitmap_Destroy(bmp);
        }
    }

    void ShowPage(int number)
    {
        if (doc == IntPtr.Zero ||
            number < 0 || number >= pageCount)
            return;
        IntPtr page = PDF.FPDF_LoadPage(doc, number);
        if (page == IntPtr.Zero)
            return;
        try
        {
            pageWidth = PDF.FPDF_GetPageWidth(page);
            pageHeight = PDF.FPDF_GetPageHeight(page);
            if (fitMode)
            {
                double w = pageWidth;
                double h = pageHeight;
                if (rotation == 1 || rotation == 3)
                {
                    double t = w;
                    w = h;
                    h = t;
                }
                double sx =
                    Math.Max(1, scroll.ClientSize.Width - 30) / w;
                double sy =
                    Math.Max(1, scroll.ClientSize.Height - 30) / h;
                zoom = fitWidth ? sx : Math.Min(sx, sy);
            }
            Bitmap image = Render(page, zoom, rotation);
            Image old = picture.Image;
            picture.Image = image;
            picture.Size = image.Size;
            if (old != null)
                old.Dispose();
            picture.Location = new Point(10, 10);
            pageNo = number;
            selectionStart = -1;
            selectionEnd = -1;
            scroll.AutoScrollPosition = new Point(0, 0);
            picture.Invalidate();
            status.Text = "Page " + (pageNo + 1) +
                " / " + pageCount +
                "     Zoom " + (int)(zoom * 100) + "%";
        }
        finally
        {
            PDF.FPDF_ClosePage(page);
        }
    }

    void SetZoom(double value)
    {
        fitMode = false;
        zoom = Math.Max(0.15, Math.Min(8.0, value));
        ShowPage(pageNo);
    }

    void Wheel(object sender, MouseEventArgs e)
    {
        if ((Control.ModifierKeys & Keys.Control) != 0)
        {
            SetZoom(zoom * (e.Delta > 0 ? 1.15 : 0.87));
        }
        else
        {
            scroll.AutoScrollPosition = new Point(
                Math.Abs(scroll.AutoScrollPosition.X),
                Math.Max(0,
                    Math.Abs(scroll.AutoScrollPosition.Y) -
                    (e.Delta > 0 ? 100 : -100)));
        }
    }

    void Rotate(object sender, EventArgs e)
    {
        rotation = (rotation + 1) % 4;
        ShowPage(pageNo);
    }

    void BuildThumbnails()
    {
        foreach (Control c in thumbs.Controls)
        {
            PictureBox old = c as PictureBox;
            if (old != null && old.Image != null)
            {
                Image image = old.Image;
                old.Image = null;
                image.Dispose();
            }
        }
        thumbs.Controls.Clear();
        for (int i = 0; i < pageCount; i++)
        {
            IntPtr page = PDF.FPDF_LoadPage(doc, i);
            if (page == IntPtr.Zero)
                continue;
            try
            {
                Bitmap image = Render(page, 0.20, 0);
                PictureBox p = new PictureBox();
                p.Image = image;
                p.SizeMode = PictureBoxSizeMode.Zoom;
                p.Size = new Size(115, 145);
                p.BackColor = Color.White;
                p.BorderStyle = BorderStyle.FixedSingle;
                p.Margin = new Padding(8);
                p.Tag = i;
                p.Cursor = Cursors.Hand;
                p.Click += ThumbnailClick;
                Label label = new Label();
                label.Text = "Page " + (i + 1);
                label.TextAlign = ContentAlignment.MiddleCenter;
                label.Width = 115;
                label.Height = 20;
                thumbs.Controls.Add(p);
                thumbs.Controls.Add(label);
            }
            finally
            {
                PDF.FPDF_ClosePage(page);
            }
        }
    }

    void ThumbnailClick(object sender, EventArgs e)
    {
        PictureBox p = (PictureBox)sender;
        ShowPage((int)p.Tag);
    }

    PointF PageToScreen(double x, double y)
    {
        double px, py;
        switch (rotation)
        {
            case 1:
                px = y;
                py = x;
                break;
            case 2:
                px = pageWidth - x;
                py = y;
                break;
            case 3:
                px = pageHeight - y;
                py = pageWidth - x;
                break;
            default:
                px = x;
                py = pageHeight - y;
                break;
        }
        return new PointF((float)(px * zoom), (float)(py * zoom));
    }

    PointF ScreenToPage(Point point)
    {
        double x = point.X / zoom;
        double y = point.Y / zoom;
        switch (rotation)
        {
            case 1:
                return new PointF((float)y, (float)x);
            case 2:
                return new PointF((float)(pageWidth - x), (float)y);
            case 3:
                return new PointF(
                    (float)(pageWidth - y),
                    (float)(pageHeight - x));
            default:
                return new PointF((float)x, (float)(pageHeight - y));
        }
    }

    int GetCharacter(Point point)
    {
        if (doc == IntPtr.Zero)
            return -1;
        IntPtr page = PDF.FPDF_LoadPage(doc, pageNo);
        if (page == IntPtr.Zero)
            return -1;
        try
        {
            IntPtr text = PDF.FPDFText_LoadPage(page);
            if (text == IntPtr.Zero)
                return -1;
            try
            {
                PointF p = ScreenToPage(point);
                double tolerance = 5.0 / zoom;
                return PDF.FPDFText_GetCharIndexAtPos(
                    text, p.X, p.Y, tolerance, tolerance);
            }
            finally
            {
                PDF.FPDFText_ClosePage(text);
            }
        }
        finally
        {
            PDF.FPDF_ClosePage(page);
        }
    }

    void DrawRange(
        Graphics g, IntPtr text,
        int start, int count, Brush brush)
    {
        if (start < 0 || count <= 0)
            return;
        for (int i = start; i < start + count; i++)
        {
            double left, right, bottom, top;
            if (PDF.FPDFText_GetCharBox(
                text, i, out left, out right,
                out bottom, out top) == 0)
                continue;
            PointF a = PageToScreen(left, bottom);
            PointF b = PageToScreen(left, top);
            PointF c = PageToScreen(right, top);
            PointF d = PageToScreen(right, bottom);
            float minX = Math.Min(Math.Min(a.X, b.X), Math.Min(c.X, d.X));
            float maxX = Math.Max(Math.Max(a.X, b.X), Math.Max(c.X, d.X));
            float minY = Math.Min(Math.Min(a.Y, b.Y), Math.Min(c.Y, d.Y));
            float maxY = Math.Max(Math.Max(a.Y, b.Y), Math.Max(c.Y, d.Y));
            g.FillRectangle(brush, minX, minY,
                Math.Max(1, maxX - minX),
                Math.Max(2, maxY - minY));
        }
    }

    void PaintHighlights(object sender, PaintEventArgs e)
    {
        if (doc == IntPtr.Zero ||
            (highlightStart < 0 && selectionStart < 0))
            return;
        IntPtr page = PDF.FPDF_LoadPage(doc, pageNo);
        if (page == IntPtr.Zero)
            return;
        try
        {
            IntPtr text = PDF.FPDFText_LoadPage(page);
            if (text == IntPtr.Zero)
                return;
            try
            {
                if (highlightStart >= 0 && highlightCount > 0)
                {
                    using (Brush b = new SolidBrush(
                        Color.FromArgb(105, 255, 220, 0)))
                        DrawRange(e.Graphics, text,
                            highlightStart, highlightCount, b);
                }
                if (selectionStart >= 0 && selectionEnd >= 0)
                {
                    int start = Math.Min(selectionStart, selectionEnd);
                    int count = Math.Abs(selectionEnd - selectionStart) + 1;
                    using (Brush b = new SolidBrush(
                        Color.FromArgb(110, 40, 120, 255)))
                        DrawRange(e.Graphics, text, start, count, b);
                }
            }
            finally
            {
                PDF.FPDFText_ClosePage(text);
            }
        }
        finally
        {
            PDF.FPDF_ClosePage(page);
        }
    }

    void SelectStart(object sender, MouseEventArgs e)
    {
        if (e.Button != MouseButtons.Left || doc == IntPtr.Zero)
            return;
        selectionStart = GetCharacter(e.Location);
        selectionEnd = selectionStart;
        selecting = selectionStart >= 0;
        highlightStart = -1;
        highlightCount = 0;
        picture.Invalidate();
    }

    void SelectMove(object sender, MouseEventArgs e)
    {
        if (!selecting)
            return;
        int character = GetCharacter(e.Location);
        if (character >= 0)
        {
            selectionEnd = character;
            picture.Invalidate();
        }
    }

    void SelectEnd(object sender, MouseEventArgs e)
    {
        if (!selecting)
            return;
        selecting = false;
        int character = GetCharacter(e.Location);
        if (character >= 0)
            selectionEnd = character;
        picture.Invalidate();
        if (selectionStart >= 0 && selectionEnd >= 0)
            status.Text = "Selected - Ctrl+C to copy";
    }

    void CopySelection()
    {
        if (doc == IntPtr.Zero ||
            selectionStart < 0 || selectionEnd < 0)
            return;
        int start = Math.Min(selectionStart, selectionEnd);
        int count = Math.Abs(selectionEnd - selectionStart) + 1;
        IntPtr page = PDF.FPDF_LoadPage(doc, pageNo);
        if (page == IntPtr.Zero)
            return;
        try
        {
            IntPtr text = PDF.FPDFText_LoadPage(page);
            if (text == IntPtr.Zero)
                return;
            try
            {
                ushort[] chars = new ushort[count + 1];
                int copied = PDF.FPDFText_GetText(
                    text, start, count, chars);
                StringBuilder result = new StringBuilder();
                for (int i = 0; i < copied && i < chars.Length; i++)
                {
                    if (chars[i] == 0)
                        break;
                    result.Append((char)chars[i]);
                }
                if (result.Length > 0)
                {
                    Clipboard.SetText(result.ToString());
                    status.Text = "Copied " + result.Length + " characters";
                }
            }
            finally
            {
                PDF.FPDFText_ClosePage(text);
            }
        }
        finally
        {
            PDF.FPDF_ClosePage(page);
        }
    }

    protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
    {
        if (keyData == (Keys.Control | Keys.C))
        {
            CopySelection();
            return true;
        }
        if (keyData == Keys.PageDown)
        {
            ShowPage(pageNo + 1);
            return true;
        }
        if (keyData == Keys.PageUp)
        {
            ShowPage(pageNo - 1);
            return true;
        }
        if (keyData == (Keys.Control | Keys.F))
        {
            Search(this, EventArgs.Empty);
            return true;
        }
        return base.ProcessCmdKey(ref msg, keyData);
    }

    // Start a new bounded search cycle.
    void ResetSearch()
    {
        searchTerm = "";
        searchBytes = null;
        searchStartPage = -1;
        searchCursorPage = -1;
        searchCursorChar = 0;
        searchActive = false;
        highlightStart = -1;
        highlightCount = 0;
    }

    void Search(object sender, EventArgs e)
    {
        if (doc == IntPtr.Zero)
            return;
        using (Form dialog = new Form())
        {
            dialog.Text = "Find text";
            dialog.Width = 370;
            dialog.Height = 135;
            dialog.StartPosition = FormStartPosition.CenterParent;
            dialog.FormBorderStyle = FormBorderStyle.FixedDialog;
            dialog.MaximizeBox = false;
            dialog.MinimizeBox = false;
            TextBox input = new TextBox();
            input.SetBounds(10, 10, 330, 25);
            input.Text = searchTerm;
            Button find = new Button();
            find.Text = "Find";
            find.SetBounds(240, 45, 100, 28);
            find.DialogResult = DialogResult.OK;
            dialog.Controls.Add(input);
            dialog.Controls.Add(find);
            dialog.AcceptButton = find;
            if (dialog.ShowDialog(this) != DialogResult.OK)
                return;
            string query = input.Text.Trim();
            if (query.Length == 0)
                return;
            // A new term always starts a new bounded cycle.
            ResetSearch();
            searchTerm = query;
            searchBytes = Encoding.Unicode.GetBytes(query + "\0");
            // The starting page is the page currently displayed.
            searchStartPage = pageNo;
            searchCursorPage = pageNo;
            searchCursorChar = 0;
            searchActive = true;
        }
        FindNext(this, EventArgs.Empty);
    }

    // Search forward, wrap once, then stop before the start page.
    void FindNext(object sender, EventArgs e)
    {
        if (doc == IntPtr.Zero || !searchActive)
        {
            status.Text = "Use Find to enter a search term.";
            return;
        }
        int startPage = searchStartPage;
        int candidatePage = searchCursorPage;
        int candidateChar = searchCursorChar;
        // At most pageCount pages are examined.
        // The starting page is never searched a second time.
        for (int checkedPages = 0;
             checkedPages < pageCount;
             checkedPages++)
        {
            // We have completed one full cycle.
            if (checkedPages > 0 && candidatePage == startPage)
                break;
            IntPtr page = PDF.FPDF_LoadPage(doc, candidatePage);
            if (page == IntPtr.Zero)
            {
                candidatePage = (candidatePage + 1) % pageCount;
                candidateChar = 0;
                continue;
            }
            int found = -1;
            int foundCount = 0;
            try
            {
                IntPtr text = PDF.FPDFText_LoadPage(page);
                if (text != IntPtr.Zero)
                {
                    try
                    {
                        IntPtr search = PDF.FPDFText_FindStart(
                            text, searchBytes, 0, candidateChar);
                        if (search != IntPtr.Zero)
                        {
                            try
                            {
                                if (PDF.FPDFText_FindNext(search) != 0)
                                {
                                    found =
                                        PDF.FPDFText_GetSchResultIndex(search);
                                    foundCount =
                                        PDF.FPDFText_GetSchCount(search);
                                }
                            }
                            finally
                            {
                                PDF.FPDFText_FindClose(search);
                            }
                        }
                    }
                    finally
                    {
                        PDF.FPDFText_ClosePage(text);
                    }
                }
            }
            finally
            {
                PDF.FPDF_ClosePage(page);
            }
            if (found >= 0 && foundCount > 0)
            {
                // Remember the next character, so the next click
                // continues after this occurrence.
                searchCursorPage = candidatePage;
                searchCursorChar = found + foundCount;
                highlightStart = found;
                highlightCount = foundCount;
                selectionStart = -1;
                selectionEnd = -1;
                ShowPage(candidatePage);
                picture.Invalidate();
                status.Text = "Found '" + searchTerm +
                    "' on page " + (candidatePage + 1);
                return;
            }
            // No more matches on this page.
            candidatePage = (candidatePage + 1) % pageCount;
            candidateChar = 0;
        }
        // Do not restart from the beginning.
        // Keep the last successful highlight and cursor.
        status.Text = "No more matches for '" + searchTerm + "'.";
        System.Media.SystemSounds.Beep.Play();
    }

    // Printing: fit source page to the selected paper's printable area.
    void Print(object sender, EventArgs e)
    {
        if (doc == IntPtr.Zero)
            return;
        printer = new PrintDocument();
        printer.DocumentName = "PDF document";
        printer.BeginPrint += delegate
        {
            printPage = 0;
        };
        printer.PrintPage += PrintPage;
        try
        {
            using (PrintDialog d = new PrintDialog())
            {
                d.Document = printer;
                d.UseEXDialog = true;
                if (d.ShowDialog() == DialogResult.OK)
                    printer.Print();
            }
        }
        finally
        {
            printer.Dispose();
            printer = null;
        }
    }

    void PrintPage(object sender, PrintPageEventArgs e)
    {
        if (printPage >= pageCount)
        {
            e.HasMorePages = false;
            return;
        }
        IntPtr page = PDF.FPDF_LoadPage(doc, printPage);
        if (page == IntPtr.Zero)
            throw new Exception("Cannot load print page.");
        try
        {
            double w = PDF.FPDF_GetPageWidth(page);
            double h = PDF.FPDF_GetPageHeight(page);
            Rectangle bounds = e.MarginBounds;
            double dpiX = Math.Min(300, e.Graphics.DpiX);
            double dpiY = Math.Min(300, e.Graphics.DpiY);
            double availableWidth = bounds.Width * dpiX / 100.0;
            double availableHeight = bounds.Height * dpiY / 100.0;
            double scale = Math.Min(
                availableWidth / w,
                availableHeight / h);
            Bitmap image = Render(page, scale, 0);
            try
            {
                e.Graphics.DrawImage(
                    image,
                    bounds.Left,
                    bounds.Top,
                    bounds.Width,
                    bounds.Height);
            }
            finally
            {
                image.Dispose();
            }
            printPage++;
            e.HasMorePages = printPage < pageCount;
        }
        finally
        {
            PDF.FPDF_ClosePage(page);
        }
    }

    void CloseDocument()
    {
        ResetSearch();
        if (doc != IntPtr.Zero)
        {
            PDF.FPDF_CloseDocument(doc);
            doc = IntPtr.Zero;
        }
        if (picture != null && picture.Image != null)
        {
            Image old = picture.Image;
            picture.Image = null;
            old.Dispose();
        }
        if (thumbs != null)
        {
            foreach (Control c in thumbs.Controls)
            {
                PictureBox p = c as PictureBox;
                if (p != null && p.Image != null)
                {
                    Image old = p.Image;
                    p.Image = null;
                    old.Dispose();
                }
            }
            thumbs.Controls.Clear();
        }
        pageCount = 0;
        pageNo = 0;
        selectionStart = -1;
        selectionEnd = -1;
        highlightStart = -1;
        highlightCount = 0;
    }
}
