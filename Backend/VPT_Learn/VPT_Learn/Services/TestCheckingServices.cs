// @TestCheckingService.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VPT_Learn.Models;

namespace VPT_Learn.Services
{
    public class TestCheckingService
    {
        /// <summary>
        /// Проверяет ответы пользователя и возвращает результат по каждому вопросу
        /// </summary>
        /// <param name="exercises">Список вопросов теста</param>
        /// <param name="userAnswers">Список ответов пользователя</param>
        /// <returns>Результат проверки с деталями по каждому вопросу</returns>
        public TestResult CheckUserAnswers(List<Exercise> exercises, List<UserTestAnswer> userAnswers)
        {
            if (exercises == null || !exercises.Any())
                throw new ArgumentException("Список вопросов не может быть пустым");
            
            if (userAnswers == null)
                userAnswers = new List<UserTestAnswer>();
            
            var results = new List<ExerciseResult>();
            int correctCount = 0;
            
            foreach (var exercise in exercises)
            {
                // Находим ответ пользователя на текущий вопрос
                var userAnswer = userAnswers.FirstOrDefault(a => a.ExerciseId == exercise.ExerciseId);
                
                bool isCorrect = false;
                
                if (userAnswer != null)
                {
                    // Проверяем, совпадает ли выбранный ID ответа с правильным ID ответа
                    // Предполагается, что exercise.RightAnswer хранит ID правильного ответа из таблицы answers
                    isCorrect = (userAnswer.SelectedAnswerId == exercise.RightAnswer);
                }
                
                if (isCorrect)
                    correctCount++;
                
                results.Add(new ExerciseResult
                {
                    QuestionId = exercise.ExerciseId,
                    IsCorrect = isCorrect
                });
            }
            int totalQuestions = exercises.Count;
            int incorrectCount = totalQuestions - correctCount;
            double scorePercentage = totalQuestions > 0 ? (correctCount * 100.0 / totalQuestions) : 0;

            return new TestResult
            {
                Results = results,
                TotalQuestions = totalQuestions,
                CorrectCount = correctCount,
                IncorrectCount = incorrectCount,
                ScorePercentage = Math.Round(scorePercentage, 2)
            };
        }
    }
    
    public class QuestionDetail
    {
        public int ExerciseId { get; set; }
        public string TaskDescription { get; set; }
        public bool IsCorrect { get; set; }
        public int UserSelectedAnswerId { get; set; }
        public string UserSelectedAnswerText { get; set; }
        public string CorrectAnswerText { get; set; }
        public int CorrectAnswerId { get; set; }
    }
}

// @UserTestAnswers.cs
namespace VPT_Learn.Models
{
    public class UserTestAnswer
    {
        public int ExerciseId { get; set; }  // ID вопроса
        public int SelectedAnswerId { get; set; }  // ID выбранного ответа (из таблицы answers)
    }
    
    public class TestResult
    {
        public List<ExerciseResult> Results { get; set; }
        public int TotalQuestions { get; set; }
        public int CorrectCount { get; set; }
        public int IncorrectCount { get; set; }
        public double ScorePercentage { get; set; }
    }
}