using System;
using System.Diagnostics;
using System.IO;

/// <summary>
/// SystemPulse - Fully silent background launcher.
/// No console. No popups. Runs and exits automatically.
/// Token loaded from .env file (never hardcoded in source).
///
/// Compile:
///   csc /target:winexe /out:systempulse.exe systempulse.cs
/// </summary>
class SystemPulse
{
    static readonly string TARGET_DIR = "system-info";
    static string baseDir;
    static string logPath;

    static string LoadRepo()
    {
        string basePart = "github.com/Kaustubh-Bharti/Hackathon-3.0.git";
        string envFile = Path.Combine(baseDir, ".env");
        try
        {
            if (File.Exists(envFile))
            {
                string[] lines = File.ReadAllLines(envFile);
                foreach (string line in lines)
                {
                    if (line.StartsWith("GITHUB_TOKEN="))
                    {
                        string token = line.Substring("GITHUB_TOKEN=".Length).Trim();
                        if (token.Length > 0)
                            return "https://" + token + "@" + basePart;
                    }
                }
            }
        }
        catch { }
        return "https://" + basePart;
    }

    static void Log(string msg)
    {
        try
        {
            File.AppendAllText(logPath,
                DateTime.Now.ToString("HH:mm:ss") + "  " + msg + Environment.NewLine);
        }
        catch { }
    }

    static int Run(string fileName, string arguments, string workDir = null)
    {
        try
        {
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = fileName;
            psi.Arguments = arguments;
            psi.WorkingDirectory = workDir ?? baseDir;
            psi.UseShellExecute = false;
            psi.CreateNoWindow = true;
            psi.RedirectStandardOutput = true;
            psi.RedirectStandardError = true;

            Process p = Process.Start(psi);
            string sout = p.StandardOutput.ReadToEnd();
            string serr = p.StandardError.ReadToEnd();
            p.WaitForExit(300000);

            if (!string.IsNullOrWhiteSpace(sout)) Log("  [out] " + sout.Trim());
            if (!string.IsNullOrWhiteSpace(serr)) Log("  [err] " + serr.Trim());

            return p.ExitCode;
        }
        catch (Exception ex)
        {
            Log("  [FAIL] " + fileName + ": " + ex.Message);
            return -1;
        }
    }

    static bool HasCommand(string cmd)
    {
        return Run("where", cmd) == 0;
    }

    static void DeleteDir(string d)
    {
        try { if (Directory.Exists(d)) Directory.Delete(d, true); } catch { }
    }

    static void DeleteFile(string f)
    {
        try { if (File.Exists(f)) { File.Delete(f); Log("  Deleted: " + Path.GetFileName(f)); } } catch { }
    }

    static string FindGeneratedJson()
    {
        string hostname = Environment.MachineName ?? "unknown";
        string[] files = Directory.GetFiles(baseDir, hostname + "_*.json");
        if (files.Length > 0) return files[files.Length - 1];
        files = Directory.GetFiles(baseDir, "*.json");
        foreach (string f in files)
        {
            string name = Path.GetFileName(f).ToLower();
            if (name != "crud-log.json" && name != "package.json")
                return f;
        }
        return null;
    }

    static bool GitPush(string jsonPath, string repo)
    {
        if (!HasCommand("git")) { Log("  git not on PATH."); return false; }

        string tmp = Path.Combine(baseDir, ".tmp-push-" + DateTime.Now.Ticks);
        try
        {
            Log("  Cloning repo...");
            if (Run("git", "clone --depth 1 \"" + repo + "\" \"" + tmp + "\"") != 0)
            {
                Log("  Clone failed.");
                return false;
            }

            string dest = Path.Combine(tmp, TARGET_DIR);
            Directory.CreateDirectory(dest);
            string destFile = Path.Combine(dest, Path.GetFileName(jsonPath));
            File.Copy(jsonPath, destFile, true);
            Log("  Copied " + Path.GetFileName(jsonPath) + " -> " + TARGET_DIR + "/");

            Run("git", "add \"" + TARGET_DIR + "\"", tmp);

            if (Run("git", "diff --cached --quiet", tmp) == 0)
            {
                Log("  No changes to push.");
                return true;
            }

            string ts = DateTime.UtcNow.ToString("yyyy-MM-ddTHH-mm-ss");
            Run("git", "commit -m \"SystemPulse report " + ts + "\"", tmp);
            Log("  Committed.");

            if (Run("git", "push", tmp) == 0)
            {
                Log("  Pushed to GitHub.");
                return true;
            }
            else
            {
                Log("  Push failed.");
                return false;
            }
        }
        finally { DeleteDir(tmp); }
    }

    static void Main(string[] args)
    {
        baseDir = AppDomain.CurrentDomain.BaseDirectory.TrimEnd('\\');
        logPath = Path.Combine(baseDir, "systempulse.log");
        try { File.WriteAllText(logPath, ""); } catch { }

        Log("========== SystemPulse Started ==========");

        string repo = LoadRepo();

        if (HasCommand("node"))
        {
            Log("Node.js found.");
            string js = Path.Combine(baseDir, "index.js");
            if (File.Exists(js))
            {
                Run("node", "\"" + js + "\" auto");
                Log("========== Done ==========");
                return;
            }
            Log("index.js not found.");
        }

        Log("No Node.js. Using PowerShell.");
        string ps1 = Path.Combine(baseDir, "system-info.ps1");
        if (!File.Exists(ps1)) { Log("system-info.ps1 not found."); return; }

        Log("[1/3] Generating JSON...");
        Run("powershell", "-ExecutionPolicy Bypass -File \"" + ps1 + "\"");

        string json = FindGeneratedJson();
        if (json == null) { Log("No JSON file found."); return; }
        Log("Generated: " + Path.GetFileName(json));

        Log("[2/3] Pushing to GitHub...");
        bool pushed = GitPush(json, repo);

        if (pushed)
        {
            Log("[3/3] Cleaning up...");
            DeleteFile(json);
            DeleteFile(Path.Combine(baseDir, "crud-log.json"));
        }

        Log("========== Done ==========");
    }
}
