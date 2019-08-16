package main

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

func zipDeCompressCurrentPath(zipFile, dest string) error {
	or ,err := zip.OpenReader(zipFile)
	defer or.Close()
	if err!=nil {return  err}

	log.Print(" 压缩文件",zipFile," 解压到",dest )
	for _,item := range or.File  {
		log.Print(dest+item.Name)
		names := strings.Split(item.Name, "/")
		log.Print(len(names))
		log.Print(names)
		if !strings.EqualFold(strings.Join(names[:1],""),
			strings.Join(strings.Split(filepath.Base(zipFile),".")[:1],"")) {

			if item.FileInfo().IsDir() {
				os.Mkdir(dest+item.Name, 0777)
				continue
			}
			rc, _ := item.Open()
			dst, _ := createFile(dest + item.Name)
			_, err := io.Copy(dst, rc)
			if err != nil {
				log.Print(err)
			}
		} else {
			filename := strings.Join(names[1:], "/")
			if item.FileInfo().IsDir() {
				os.Mkdir(dest+filename, 0777)
				continue
			}
			rc, _ := item.Open()
			dst, _ := createFile(dest + filename)
			_, err := io.Copy(dst, rc)
			if err != nil {
				log.Print(err)
			}
		}

	}

	return nil
}

func zipDeCompress(zipFile, dest string) error {
	or ,err := zip.OpenReader(zipFile)
	defer or.Close()
	if err!=nil {return  err}

	log.Print(" 压缩文件",zipFile," 解压到",dest )

	for _,item := range or.File  {
		log.Print(dest+item.Name)
		if item.FileInfo().IsDir() {
			os.Mkdir(dest+item.Name, 0777)
			continue
		}
		rc, _ := item.Open()
		dst,_ := createFile(dest+item.Name)
		_,err :=io.Copy(dst,rc)
		if err!=nil { log.Print(err) }
	}

	return nil
}

func DeCompress1(zipFile, dest string) error {
	reader, err := zip.OpenReader(zipFile)
	if err != nil {
		return err
	}
	defer reader.Close()
	for _, file := range reader.File {
		rc, err := file.Open()
		if err != nil {
			return err
		}
		defer rc.Close()
		filename := dest + file.Name
		err = os.MkdirAll(getDir(filename), 0755)
		if err != nil {
			return err
		}
		w, err := os.Create(filename)
		if err != nil {
			return err
		}
		defer w.Close()
		_, err = io.Copy(w, rc)
		if err != nil {
			return err
		}
		w.Close()
		rc.Close()
	}
	return nil
}

func getDir(path string) string {
	return subString(path, 0, strings.LastIndex(path, "/"))
}

func subString(str string, start, end int) string {
	rs := []rune(str)
	length := len(rs)

	if start < 0 || start > length {
		panic("start is wrong")
	}

	if end < start || end > length {
		panic("end is wrong")
	}

	return string(rs[start:end])
}


func createFile(name string) (*os.File, error) {
	err := os.MkdirAll(string([]rune(name)[0:strings.LastIndex(name, "/")]), 0755)
	if err != nil {
		return nil, err
	}
	return os.Create(name)
}

// 判断路径文件/文件夹是否存在
func Exists(path string) bool {
	_, err := os.Stat(path)    //os.Stat获取文件信息
	if err != nil {
		if os.IsExist(err) {
			return true
		}
		return false
	}
	return true
}


func isDirExists(path string) bool {
	fi, err := os.Stat(path)

	if err != nil {
		return os.IsExist(err)
	} else {
		return fi.IsDir()
	}

	panic("not reached")
}
// 判断所给路径是否为文件夹
func IsDir(path string) bool {
	s, err := os.Stat(path)
	if err != nil {
		return false
	}
	return s.IsDir()
}

// 判断所给路径是否为文件
func IsFile(path string) bool {
	return !IsDir(path)
}