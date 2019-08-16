package util

import (
	"os"
	"path/filepath"
	"unicode/utf8"
	"archive/zip"
	"log"
	"io"
	"strings"
)

var txtExt = map[string]bool{
	".js":    true,
	".json":  true,
	".html":  true,
	".md":    true,
	".rst":   true,
	".php":   true,
	".conf":  true,
	".go":    true,
	".css":   true,
	".py":    true,
	".log":   true,
	".pl":    true,
	".cofee": true,
	".dart":  true,
	".sql":   true,
}

// Take from here
// https://code.google.com/p/go/source/browse/godoc/util/util.go?repo=tools

func IsTextFile(filename string) bool {

	if istxt, found := txtExt[filepath.Ext(filename)]; found {
		return istxt
	}

	f, err := os.Open(filename)
	if err != nil {
		return false
	}
	defer f.Close()

	var buf [1024]byte
	n, err := f.Read(buf[0:])
	if err != nil {
		return false
	}

	return IsText(buf[0:n])

}

// IsText reports whether a significant prefix of s looks like correct UTF-8;
// that is, if it is likely that s is human-readable text.
func IsText(s []byte) bool {
	const max = 1024 // at least utf8.UTFMax
	if len(s) > max {
		s = s[0:max]
	}
	for i, c := range string(s) {
		if i+utf8.UTFMax > len(s) {
			// last char may be incomplete - ignore
			break
		}
		if c == 0xFFFD || c < ' ' && c != '\n' && c != '\t' && c != '\f' {
			// decoding error or control character - not a text file
			return false
		}
	}
	return true
}

func DeCompress(tarFile, dest string) error {
	if strings.HasSuffix(tarFile,".zip"){
		return zipDeCompress(tarFile,dest)
	}
	return nil
}


func zipDeCompress(zipFile, dest string) error {
	or ,err := zip.OpenReader(zipFile);
	defer or.Close()
	if err!=nil {return  err}

	log.Print(" 压缩文件",zipFile," 解压到",dest )

	for _,item := range or.File  {
		log.Print(dest+item.Name)
		if item.FileInfo().IsDir(){os.Mkdir(dest+item.Name,0777);continue}
		rc, _ := item.Open()
		dst,_ := createFile(dest+item.Name);
		_,err :=io.Copy(dst,rc)
		if err!=nil { log.Print(err) }
	}

	return nil
}

func createFile(name string) (*os.File, error) {
	err := os.MkdirAll(string([]rune(name)[0:strings.LastIndex(name, "/")]), 0755)
	if err != nil {
		return nil, err
	}
	return os.Create(name)
}
