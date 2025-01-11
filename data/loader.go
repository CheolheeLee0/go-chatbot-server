package data

import (
	"encoding/csv"
	"os"
	"strconv"
	"strings"

	"github.com/tmc/langchaingo/schema"
)

func LoadDocuments(filename string) ([]schema.Document, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		return nil, err
	}

	var docs []schema.Document
	for i, record := range records {
		if i == 1 {
			// Print the header row
			println("Header:", strings.Join(record, ", "))
			continue
		}
		no, _ := strconv.Atoi(record[0])
		doc := schema.Document{
			PageContent: record[5], // Answer column
			Metadata: map[string]any{
				"no":           no,
				"industry":     record[1],
				"category":     record[2],
				"sub_category": record[3],
				"question":     record[4],
				"keywords":     record[6], // Store keywords as a comma-separated string
			},
		}
		docs = append(docs, doc)
	}

	return docs, nil
}
