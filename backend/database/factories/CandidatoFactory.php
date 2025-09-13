<?php

namespace Database\Factories;

use App\Models\Candidato;
use Illuminate\Database\Eloquent\Factories\Factory;

class CandidatoFactory extends Factory
{
    protected $model = Candidato::class;

    public function definition(): array
    {
        return [
            'nome'  => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
        ];
    }
}
